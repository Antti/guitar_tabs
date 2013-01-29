module GuitarTabs::GuitarPro::GP5
  def read_song
    read_info
    read_lyrics
    read_page_setup
    @tempo_name = read_int_size_check_byte_string
    @tempo = read_int
    @hide_tempo = read_bool if version.minor > 0
    @key = read_byte
    @octave = read_int
    read_midi_channels
    skip(42)
    @measureCount = read_int
    @trackCount = read_int
    # this.readMeasureHeaders(song,measureCount);
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
end
