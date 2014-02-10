module GuitarTabs
  class GuitarPro::GPX
    require 'guitar_tabs/guitar_pro/gpx/file_system'
    def initialize(io)
      @io = io
      @filesystem = FileSystem.new(io)
      @filesystem.load
    end
  end
end