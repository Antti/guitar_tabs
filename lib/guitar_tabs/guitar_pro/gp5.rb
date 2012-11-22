module GuitarTabs::GuitarPro::GP5
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
end
