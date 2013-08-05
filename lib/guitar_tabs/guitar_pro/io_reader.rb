class GuitarTabs::GuitarPro::IOReader
  class IOError < StandardError; end
  attr_reader :io
  def initialize(io, encoding='cp1251')
    @io, @encoding = io, encoding
    @io.set_encoding(@encoding)
  end
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
    @io.read(str_size).encode('utf-8')
  rescue
    raise IOError
  end

  # String is actually len lenght, but read str_len - 1 every time
  def read_string(size=0)
    len = read_byte
    c = size > 0 ? size : len
    @io.read(c).encode('utf-8')
  rescue
    raise IOError
  end

  #Read 1 byte
  def read_byte
    @io.getbyte
  rescue
    raise IOError
  end

  def read_bool
    read_byte != 0
  end

  # Read GP int (4 bytes)
  def read_int
    bytes = @io.read(4).unpack('L').first
  rescue
    raise IOError
  end

  def skip(count)
    seek(count, IO::SEEK_CUR)
  end

  def seek(count, pos)
    @io.seek(count, pos)
  rescue
    raise IOError
  end
end