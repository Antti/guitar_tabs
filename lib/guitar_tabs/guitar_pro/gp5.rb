module GuitarTabs::GuitarPro::GP5
  def read_song
    logger.debug "Reading info"
    read_info
    logger.debug "Reading lyrics"
    read_lyrics
    logger.debug "Reading page setup"
    read_page_setup
    logger.debug "Reading tempo information"
    @tempo_name = read_int_size_check_byte_string
    @tempo = read_int
    @hide_tempo = read_bool if version.minor > 0
    logger.debug "Tempo name: #{@tempo_name}, tempo: #{@tempo}, hide tempo: #{@hide_tempo}"
    @key = read_byte
    @octave = read_int
    logger.debug "Reading midi channels"
    read_midi_channels
    skip(42)
    logger.debug "Reading measure_count"
    @measure_count = read_int
    logger.debug "Measures count: #{@measure_count}"
    @track_count = read_int
    logger.debug "Tracks count: #{@track_count}"
    logger.debug "Reading measure headers"
    read_measure_headers
    # this.readTracks(song,trackCount,channels);
    # this.readMeasures(song);
  end

  def read_info
    @title = read_string_int
    @subtitle = read_string_int
    @artist = read_string_int
    @album = read_string_int
    @author = read_string_int
    @copyright = read_string_int
    @writer = read_string_int
    @instruction = read_string_int
    read_string_int # Something?
    @comments = read_string_array_with_length.join('')
  end

  def read_lyrics
    @lyrics_track_number = read_int
    @lyrics = 5.times.map do
      #measure_number, str
      [read_int, read_string_int2]
    end
  end

  def read_page_setup
    @page_setup = GuitarTabs::GuitarPro::PageSetup.new
    skip(19) if version.minor > 1
    @page_setup.page_size = [read_int, read_int]
    l, r , t, b = read_int, read_int, read_int, read_int
    @page_setup.page_margin = [l, r, t, b]
    @page_setup.score_size_proportion = read_int / 100.0
    @page_setup.header_and_footer = read_byte
    flags2 = read_byte
    @page_setup.header_and_footer |= 256 if (flags2 & 1) != 0
    @page_setup.title = read_int_size_check_byte_string
    @page_setup.subtitle = read_int_size_check_byte_string
    @page_setup.artist = read_int_size_check_byte_string
    @page_setup.album = read_int_size_check_byte_string
    @page_setup.words = read_int_size_check_byte_string
    @page_setup.music = read_int_size_check_byte_string
    @page_setup.words_and_music = read_int_size_check_byte_string
    @page_setup.copyright = "#{read_int_size_check_byte_string}\n#{read_int_size_check_byte_string}"
    @page_setup.page_number = read_int_size_check_byte_string
  end

  def read_measure_header(idx)
    logger.debug "Reading measue header #{idx}"
    skip(1) if (idx > 0)
    flags = read_byte
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
    header.time_signature.numerator = read_byte if (flags & 0x01) != 0
    header.time_signature.denominator = read_byte if (flags & 0x02) != 0
    header.begin_repeat = (flags & 0x04) != 0 # Beginning of repeat
    header.end_repeat = (read_byte - 1) if (flags & 0x08) != 0 # End of repeat
    header.marker = read_marker if (flags & 0x20) != 0 # Marker
    header.repeat_alternative = read_byte if (flags & 0x10) != 0 # Number of alternate endings
    if (flags & 0x40) != 0 #Tonality
      header.key_signature = read_byte
      header.key_signature_type = read_byte
    elsif header.number > 1 #We copy key signature from a previous measure_header
      header.key_signature = measure_headers[idx - 1].key_signature
      header.key_signature_type = measure_headers[idx - 1].key_signature_type
    end
    skip(4) if (flags & 0x01) != 0
    skip(1) if (flags & 0x10) != 0
    header.triplet_feel = read_byte #1/2/0
    logger.debug("Read measure header: #{header}")
    header
  end
end
