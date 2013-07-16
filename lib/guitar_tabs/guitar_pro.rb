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
    # @param[IO] file input stream
    def initialize(file)
      @file = file
      read_version
      #read_song
    end

    def read_version
      begin
        @version_string = read_string.tap {@file.seek(31,IO::SEEK_SET)} #We need to skip the rest of a free space.
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

    private
    # Read chunk size and read string with a given size.
    def read_string_int
      str_size = read_int
      read_string(str_size-1)
    end

    alias_method :read_int_size_check_byte_string, :read_string_int

    # Read array of int_strings
    def read_string_array_with_length
      read_int.times.map{read_string_int}
    end

    # Read string size and string
    def read_string_int2
      str_size = read_int
      @file.read(str_size).force_encoding('cp1251').encode('utf-8')
    end

    # String is actually len lenght, but read str_len - 1 every time
    def read_string(size=0)
      len = read_byte
      c = size > 0 ? size : len
      @file.read(c).force_encoding('cp1251').encode('utf-8')
    end

    #Read 1 byte
    def read_byte
      @file.getbyte
    end

    def read_bool
      read_byte != 0
    end

    # Read GP int (4 bytes)
    def read_int
      bytes = @file.read(4).bytes.to_a
      bytes[3] << 24 | bytes[2] << 16 | bytes[1] << 8 | bytes[0]
    end

    def skip(count)
      @file.seek(count,IO::SEEK_CUR)
    end

    def read_midi_channels
      @midi_channels = 1.upto(MIDI_CHANNELS_COUNT).map do |g|
        channel = MidiChannel.new
        channel.channel = g
        channel.effect_channel = g
        channel.instrument = read_int
        channel.volume = read_byte
        channel.balance  = read_byte
        channel.chorus = read_byte
        channel.reverb = read_byte
        channel.phaser = read_byte
        channel.tremolo = read_byte
        skip(2)
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
      title = read_int_size_check_byte_string
      color = read_color
      marker = Marker.new(title, color)
      logger.debug "Read marker #{marker}"
      marker
    end

    def read_color
      Color.new(read_byte, read_byte, read_byte, read_byte)
    end

    def logger
      @logger ||= Yell.new(STDOUT)
    end

    autoload :GP3, 'guitar_tabs/guitar_pro/gp3'
    autoload :GP4, 'guitar_tabs/guitar_pro/gp4'
    autoload :GP5, 'guitar_tabs/guitar_pro/gp5'
    autoload :GP6, 'guitar_tabs/guitar_pro/gp6'
    autoload :Version, 'guitar_tabs/guitar_pro/version'
  end
end

