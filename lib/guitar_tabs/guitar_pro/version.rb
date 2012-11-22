class GuitarTabs::GuitarPro::Version
  include Comparable
  attr_reader :major, :minor, :version_string

  # @param[String] version_string "FISCHIER GUITAR PRO v5.10"
  def self.from_string(version_string)
    match = /v(\d+)\.(\d+)/.match(version_string)
    raise UnknownVersion unless match
    major = match[1].to_i
    minor = match[2].to_i
    self.new(major, minor, version_string)
  end

  def initialize(major, minor, version_string='')
    @major, @minor = major, minor
    @version_string = version_string
  end

  def <=>(other)
    if other.major > self.major || (other.major == self.major && other.minor > self.minor)
      -1
    elsif self.major > other.major || (self.major == other.major && self.minor > other.minor)
      1
    else
      0
    end
  end

  def to_s
    "#{major}.#{minor} #{version_string}"
  end

  class UnknownVersion < StandardError; end
end
