# encoding: utf-8
require 'yell'
module GuitarTabs
  class GuitarPro
    attr_reader :reader
    private :reader

    # @param[IO] io input stream
    def initialize(io, load_tab=false)
      @reader = GP345Reader.new(io)
      #@reader.load
    end

    def info
      @reader.info
    end

    def version
      @reader.version
    end

    def info_hash
      {
        title: info.title,
        subtitle: info.subtitle,
        artist: info.artist,
        album: info.album,
        author: info.author,
        copyright: info.copyright,
        writer: info.writer,
        instruction: info.instruction,
        comments: info.comments,
        gp_version: version.to_s
      }
    end

private
    autoload :GP345Reader, 'guitar_tabs/guitar_pro/gp345_reader'
    autoload :Version, 'guitar_tabs/guitar_pro/version'
  end
end

