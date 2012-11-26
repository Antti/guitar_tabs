# encoding: utf-8
module GuitarTabs
  class GuitarPro
    class InvalidFile < StandardError; end
    attr_reader :comments, :version
    attr_reader :title, :subtitle, :artist, :album, :author, :copyright, :writer, :instruction
    # @param[IO] file input stream
    def initialize(file)
      @file = file
      read_header
    end

    def read_header
      read_version rescue InvalidFile, "Invalid file format"
      if version.major == 3
        self.send(:extend, GP3)
      elsif version.major == 4
        self.send(:extend, GP4)
      elsif version.major == 5
        self.send(:extend, GP5)
      else
        raise InvalidFile, "Unknown version #{version}"
      end
      read_info
      #read_lyrics
    end

    def read_version
      @version_string = read_string.tap {@file.seek(31,IO::SEEK_SET)} #We need to skip the rest of a free space.
      @version = Version.from_string(@version_string)
    end

    private
    # Read chunk size and read string with a given size.
    def read_string_int
      str_size = read_int
      read_string(str_size-1)
    end

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

    # Read GP int (4 bytes)
    def read_int
      bytes = @file.read(4).bytes.to_a
      bytes[3] << 24 | bytes[2] << 16 | bytes[1] << 8 | bytes[0]
    end

    autoload :GP3, 'guitar_tabs/guitar_pro/gp3'
    autoload :GP4, 'guitar_tabs/guitar_pro/gp4'
    autoload :GP5, 'guitar_tabs/guitar_pro/gp5'
    autoload :Version, 'guitar_tabs/guitar_pro/version'
  end
end

if $0 == __FILE__
  gp = GuitarPro.new(File.new(ARGV[0]))
  #puts gp.comments
  p gp
end
