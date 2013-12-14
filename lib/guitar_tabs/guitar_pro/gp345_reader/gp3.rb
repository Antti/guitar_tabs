class GuitarTabs::GuitarPro::GP345Reader
  module GP3
    private
    def read_song
      read_lyrics
      #read_page_setup
    end

    def read_info
      info = Info.new
      info.title = reader.read_string_int
      info.subtitle = reader.read_string_int
      info.artist = reader.read_string_int
      info.album = reader.read_string_int
      info.author = reader.read_string_int
      info.copyright = reader.read_string_int
      info.writer = reader.read_string_int
      info.instruction = reader.read_string_int
      info.comments = reader.read_string_array_with_length.join('')
      info.triplet_feel = reader.read_byte
    end

    def read_lyrics
      @lyrics_track_number = reader.read_int
      @lyrics = 5.times.map do
        #measure_number, str
        [reader.read_int, reader.read_string_int2]
      end
    end
  end
end
