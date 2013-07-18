module GuitarTabs::GuitarPro::GP4
  private
  def read_song
    logger.debug "Reading info"
    read_info
    logger.debug "Reading lyrics"
    read_lyrics
    #read_page_setup
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
    @comments = reader.read_string_array_with_length.join('')
    @triplet_feel = reader.read_byte
  end

  def read_lyrics
    @lyrics_track_number = reader.read_int
    @lyrics = 5.times.map do
      #measure_number, str
      [reader.read_int, reader.read_string_int2]
    end
  end
end
