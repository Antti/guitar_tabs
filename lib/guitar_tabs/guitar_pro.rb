# encoding: utf-8
require 'yell'
module GuitarTabs
  class GuitarPro
    class InvalidFile < StandardError; end
    MIDI_CHANNELS_COUNT = 64
    PageSetup = Struct.new(:page_size, :page_margin, :score_size_proportion, :header_and_footer, :title,
      :subtitle, :artist, :album, :words, :music, :words_and_music, :copyright, :page_number)
    MidiChannel = Struct.new(:channel, :effect_channel, :instrument, :volume, :balance, :chorus, :reverb,
      :phaser, :tremolo)
    MeasureHeader = Struct.new(:flags, :number, :start, :tempo, :begin_repeat, :end_repeat, :marker, :repeat_alternative,
      :time_signature, :key_signature, :key_signature_type, :has_double_bar, :triplet_feel)
    TimeSignature = Struct.new(:numerator, :denominator)
    Marker = Struct.new(:title, :color)
    Color = Struct.new(:r,:g,:b, :a)

    attr_reader :comments, :version
    attr_reader :title, :subtitle, :artist, :album, :author, :copyright, :writer, :instruction
    attr_reader :page_setup, :tempo_name, :measure_headers
    attr_reader :reader
    private :reader
    # @param[IO] io input stream
    def initialize(io)
      @reader = IOReader.new(io)
      @loaded = false
      logger.level = 'gte.warn' unless ENV["DEBUG_GUITAR_TABS"]
    end

    def load
      return if @loaded
      read_version
      read_song
      @loaded = true
    end

private
    def read_version
      begin
        @version_string = reader.read_string #We need to skip the rest of a free space.
        reader.seek(31,IO::SEEK_SET)
        @version = Version.from_string(@version_string)
      rescue StandardError => e
        raise InvalidFile, "Invalid file format (#{e.message})"
      end
      if version.major == 3
        self.send(:extend, GP3)
      elsif version.major == 4
        self.send(:extend, GP4)
      elsif version.major == 5
        self.send(:extend, GP5)
      elsif version.major == 6
        self.send(:extend, GP6)
      else
        raise InvalidFile, "Unknown version #{version}"
      end
    end

    def read_midi_channels
      @midi_channels = 1.upto(MIDI_CHANNELS_COUNT).map do |g|
        channel = MidiChannel.new
        channel.channel = g
        channel.effect_channel = g
        channel.instrument = reader.read_int
        channel.volume = reader.read_byte
        channel.balance  = reader.read_byte
        channel.chorus = reader.read_byte
        channel.reverb = reader.read_byte
        channel.phaser = reader.read_byte
        channel.tremolo = reader.read_byte
        reader.skip(2)
        channel
      end
    end

    def read_measure_headers
      #Don't change this to map, cause read_measure_header queries previous headers
      @measure_headers = []
      0.upto(@measure_count-1) do |idx|
        @measure_headers << read_measure_header(idx)
      end
    end

    def read_marker
      title = reader.read_int_size_check_byte_string
      color = read_color
      marker = Marker.new(title, color)
      logger.debug "Read marker #{marker}"
      marker
    end

    def read_color
      Color.new(reader.read_byte, reader.read_byte, reader.read_byte, reader.read_byte)
    end

    def logger
      @logger ||= Yell.new(STDOUT)
    end

    autoload :GP3, 'guitar_tabs/guitar_pro/gp3'
    autoload :GP4, 'guitar_tabs/guitar_pro/gp4'
    autoload :GP5, 'guitar_tabs/guitar_pro/gp5'
    autoload :GP6, 'guitar_tabs/guitar_pro/gp6'
    autoload :Version, 'guitar_tabs/guitar_pro/version'
    autoload :IOReader, 'guitar_tabs/guitar_pro/io_reader'
  end
end

