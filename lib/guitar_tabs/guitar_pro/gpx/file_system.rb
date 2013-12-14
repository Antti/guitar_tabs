module GuitarTabs::GuitarPro::GPX
  class FileSystem
    HEADER_BCFS = 1397113666
    HEADER_BCFZ = 1514554178
    #http://app.ultimate-guitar.com/iphone/tab.php?app_platform=&id=1078654

    attr_reader :io
    def initialize(io)
      @io = io
    end

    def load
      header = read_int
      case header
        when HEADER_BCFS
          load_bcfs
        when HEADER_BCFZ
          load_bcfz
        else
          raise 'Not a valid gpx file'
      end
    end

    def file_names

    end

    def file_context(file_name)

    end

    def load_bcfs
      sector_size = 0x1000
      offset = 0
      while ( (offset = (offset + sector_size)) + 3 < @io.length )
        if read_int(offset) == 2
          index_file_name = (offset + 4)
          index_file_size = (offset + 0x8C)
          index_of_block  = (offset + 0x94)
          block = 0
          block_count = 0
        end
      end
    end

    def load_bcfz

    end

    def read_int(offset=0)
      cur_off = @io.offset
      @io.seek(offset, IO::SEEK_SET)
      int = @io.read(4).unpack('L').first
      @io.seek(cur_off, IO::SEEK_SET)
      int
    end

  end

end