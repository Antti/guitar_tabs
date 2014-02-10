require 'guitar_tabs/guitar_pro/gpx/io'
module GuitarTabs
  class GuitarPro::GPX::FileSystem
    HEADER_BCFS = 1397113666
    HEADER_BCFZ = 1514554178
    #http://app.ultimate-guitar.com/iphone/tab.php?app_platform=&id=1078654

    def initialize(io)
      @io = GuitarTabs::GuitarPro::GPX::IO.new(io)
    end

    def load
      header = @io.read_int
      case header
        when HEADER_BCFS
          load_bcfs(@io)
        when HEADER_BCFZ
          decompressed_data = load_bcfz(@io)
          io = GuitarTabs::GuitarPro::GPX::IO.new StringIO.new(decompressed_data)
          load_bcfs(io)
        else
          raise 'Not a valid gpx file'
      end
    end

    def load_bcfs(io)
      sector_size = 0x1000
      offset = sector_size
      files = []
      while (offset + 3) < io.length
        if io.read_int(offset) == 2
          file_name = io.read_string(offset+0x04, 127)
          file_size = io.read_int(offset + 0x8C)
          files << [file_name, file_size]
          p files
          #var entryType = getInteger(data, offset);
          #
          #if (entryType == 2) // is a file?
          #  {
          #      // file structure:
          #    //   offset |   type   |   size   | what
          #//  --------+----------+----------+------
          #//    0x04  |  string  |  127byte | FileName (zero terminated)
          #//    0x83  |    ?     |    9byte | Unknown
          #//    0x8c  |   int    |    4byte | FileSize
          #//    0x90  |    ?     |    4byte | Unknown
          #//    0x94  |   int[]  |  n*4byte | Indices of the sector containing the data (end is marked with 0)
          #
          #// The sectors marked at 0x94 are absolutely positioned ( 1*0x1000 is sector 1, 2*0x1000 is sector 2,...)
          #
          #var file:GpxFile = new GpxFile();
          #file.fileName = getString(data, offset + 0x04, 127);
          #file.fileSize = getInteger(data, offset + 0x8C);
          #
          #// store file if needed
          #var storeFile = _fileFilter != null ? _fileFilter(file.fileName) : defaultFileFilter(file.fileName);
          #if (storeFile)
          #  {
          #      files.push(file);
          #  }
          #
          #  // we need to iterate the blocks because we need to move after the last datasector
          #
          #  var dataPointerOffset = offset + 0x94;
          #  var sector = 0; // this var is storing the sector index
          #  var sectorCount = 0; // we're keeping count so we can calculate the offset of the array item
          #
          #      // as long we have data blocks we need to iterate them,
          #      var fileData:BytesArray = storeFile ? new BytesArray(file.fileSize) : null;
          #      while( (sector = getInteger(data, (dataPointerOffset + (4 * (sectorCount++))))) != 0)
          #      {
          #          // the next file entry starts after the last data sector so we
          #          // move the offset along
          #          offset = sector * sectorSize;
          #
          #          // write data only if needed
          #          if (storeFile)
          #          {
          #              fileData.addBytes(data.sub(offset, sectorSize));
          #          }
          #      }
          #
          #      if (storeFile)
          #      {
          #          // trim data to filesize if needed
          #          file.data = Bytes.alloc(Std.int(Math.min(file.fileSize, fileData.length)));
          #          // we can use the getBuffer here because we are intelligent and know not to read the empty data.
          #          file.data.blit(0, fileData.getBuffer(), 0, file.data.length);
          #      }
          #   }
          #
          #  // let's move to the next sector
          #  offset += sectorSize;
          #
        end
        offset += sector_size
      end
      files
    end

    def load_bcfz(io)
      puts 'compressed'
      result = []
      expected_length = io.read_int
      puts expected_length
      while result.size < expected_length
        flag = io.read_bit
        if flag == 1
          word_size = io.read_bits(4)
          offset = io.read_bits_reversed(word_size)
          size = io.read_bits_reversed(word_size)
          source_position = result.size - offset
          to_read = [offset, size].min
          result.concat result[source_position...source_position+to_read]
        else
          size = io.read_bits_reversed(2)
          size.times {
            result << io.read_byte
          }
        end
      end
      result.pack('C*')
    rescue EOFError
      return result.pack('C*')
    end


  end
end