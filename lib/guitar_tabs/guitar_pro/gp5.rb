module GuitarTabs::GuitarPro::GP5
  private
  def read_song
    logger.debug "Reading info"
    read_info
    logger.debug "Reading lyrics"
    read_lyrics
    logger.debug "Reading page setup"
    read_page_setup
    logger.debug "Reading tempo information"
    @tempo_name = reader.read_int_size_check_byte_string
    @tempo = reader.read_int
    @hide_tempo = reader.read_bool if version.minor > 0
    logger.debug "Tempo name: #{@tempo_name}, tempo: #{@tempo}, hide tempo: #{@hide_tempo}"
    @key = reader.read_byte
    @octave = reader.read_int
    logger.debug "Reading midi channels"
    read_midi_channels
    reader.skip(42)
    logger.debug "Reading measure_count"
    @measure_count = reader.read_int
    logger.debug "Measures count: #{@measure_count}"
    @track_count = reader.read_int
    logger.debug "Tracks count: #{@track_count}"
    logger.debug "Reading measure headers"
    read_measure_headers
    # this.readTracks(song,trackCount,channels);
    # this.readMeasures(song);
  end

  def read_info
    @title = reader.read_string_int
    @subtitle = reader.read_string_int
    @artist = reader.read_string_int
    @album = reader.read_string_int
    @author = reader.read_string_int
    @copyright = reader.read_string_int
    @writer = reader.read_string_int
    @instruction = reader.read_string_int
    reader.read_string_int # Something?
    @comments = reader.read_string_array_with_length.join('')
  end

  def read_lyrics
    @lyrics_track_number = reader.read_int
    @lyrics = 5.times.map do
      #measure_number, str
      [reader.read_int, reader.read_string_int2]
    end
  end

  def read_page_setup
    @page_setup = GuitarTabs::GuitarPro::PageSetup.new
    reader.skip(19) if version.minor > 1
    @page_setup.page_size = [reader.read_int, reader.read_int]
    l, r , t, b = reader.read_int, reader.read_int, reader.read_int, reader.read_int
    @page_setup.page_margin = [l, r, t, b]
    @page_setup.score_size_proportion = reader.read_int / 100.0
    @page_setup.header_and_footer = reader.read_byte
    flags2 = reader.read_byte
    @page_setup.header_and_footer |= 256 if (flags2 & 1) != 0
    @page_setup.title = reader.read_int_size_check_byte_string
    @page_setup.subtitle = reader.read_int_size_check_byte_string
    @page_setup.artist = reader.read_int_size_check_byte_string
    @page_setup.album = reader.read_int_size_check_byte_string
    @page_setup.words = reader.read_int_size_check_byte_string
    @page_setup.music = reader.read_int_size_check_byte_string
    @page_setup.words_and_music = reader.read_int_size_check_byte_string
    @page_setup.copyright = "#{reader.read_int_size_check_byte_string}\n#{reader.read_int_size_check_byte_string}"
    @page_setup.page_number = reader.read_int_size_check_byte_string
  end

  def read_measure_header(idx)
    logger.debug "Reading measue header #{idx}"
    reader.skip(1) if (idx > 0)
    flags = reader.read_byte
    header = GuitarTabs::GuitarPro::MeasureHeader.new
    header.flags = flags
    header.number = idx + 1
    header.start = 0
    header.tempo = @tempo
    header.time_signature = if measure_headers[idx - 1]
       measure_headers[idx - 1].time_signature.clone
    else
      GuitarTabs::GuitarPro::TimeSignature.new
    end
    header.has_double_bar = ((flags & 0x80) != 0)
    header.time_signature.numerator = reader.read_byte if (flags & 0x01) != 0
    header.time_signature.denominator = reader.read_byte if (flags & 0x02) != 0
    header.begin_repeat = (flags & 0x04) != 0 # Beginning of repeat
    header.end_repeat = (reader.read_byte - 1) if (flags & 0x08) != 0 # End of repeat
    header.marker = read_marker if (flags & 0x20) != 0 # Marker
    header.repeat_alternative = reader.read_byte if (flags & 0x10) != 0 # Number of alternate endings
    if (flags & 0x40) != 0 #Tonality
      header.key_signature = reader.read_byte
      header.key_signature_type = reader.read_byte
    elsif header.number > 1 #We copy key signature from a previous measure_header
      header.key_signature = measure_headers[idx - 1].key_signature
      header.key_signature_type = measure_headers[idx - 1].key_signature_type
    end
    reader.skip(4) if (flags & 0x01) != 0
    reader.skip(1) if (flags & 0x10) != 0
    header.triplet_feel = reader.read_byte #1/2/0
    logger.debug("Read measure header: #{header}")
    header
  end
end
