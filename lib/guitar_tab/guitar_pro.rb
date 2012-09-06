# encoding: utf-8
class GuitarPro
  attr_reader :comments
  attr_reader :title, :subtitle, :artist, :album, :author, :copyright, :writer, :instruction
  # @param[IO] file input stream
  def initialize(file)
    @file = file
    read_header
  end

  def read_header
    read_version
    read_info
    read_lyrics
  end

  def read_version
    str_len = read_byte
    @version = @file.read(str_len).tap { @file.read(30-str_len)}
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
    comments = read_string_int_array
    @comments = comments.join('')
  end

  def read_lyrics
    @lyrics_track_number = read_int
    @lyrics = 5.times.map do
      #measure_number, str
      [read_int, read_string_int2]
    end
  end

  private
  def read_string_int
    str_size = read_int
    read_string(str_size-1)
  end

  def read_string_int_array
    read_int.times.map{read_string_int}
  end

  def read_string_int2
    str_size = read_int
    @file.read(str_size)
  end

  # String is actually chars_count lenght, but read str_len - 1 every time
  def read_string(size)
    len = read_byte
    c = size > 0 ? size : len
    @file.read(c)
  end

  def read_byte
    @file.getbyte
  end

  def read_int
    bytes = @file.read(4).bytes.to_a
    bytes[3] << 24 | bytes[2] << 16 | bytes[1] << 8 | bytes[0]
  end

end

if $0 == __FILE__
  gp = GuitarPro.new(File.new(ARGV[0]))
  #puts gp.comments
  p gp
end
