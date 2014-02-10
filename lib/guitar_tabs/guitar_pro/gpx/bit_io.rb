require 'stringio'
module GuitarTabs
  class GuitarPro::GPX::IO

    def initialize(io)
      @io = StringIO.new(io)
      @position = 8
    end

    attr_reader :io
    private :io

    def read_byte
      read_bits(8)
    end

    def length
      io.length
    end

    def read_bits(count)
      result = 0
      count.times do |i|
        result = result | (read_bit << (count - i -1))
      end
      result
    end

    def read_bits_reversed(count)
      result = 0
      count.times do |i|
        result = result | (read_bit << i)
      end
      result
    end

    def read_bit
      if @position >= 8
        @current_byte = io.readbyte
        @position = 0
      end

      #shift the desired byte to the least significant bit and
      #get the value using masking
      value = (@current_byte >> (8 - @position - 1)) & 0x01
      @position+=1
      value
    end

    def read_string(offset, length)
      i = 0
      buf = []
      io.seek(offset, IO::SEEK_SET)
      while (b = readbyte) != 0
        i+=1
        buf << b
        break if i == length
      end
      buf.pack('C*').force_encoding('utf-8')
    end

    def read_int(offset=nil)
      cur_off = io.pos
      io.seek(offset, IO::SEEK_SET) if offset
      int = 4.times.map { read_byte }.pack('C*').unpack('V').first
      io.seek(cur_off, IO::SEEK_SET) if offset
      int
    end

  end
end