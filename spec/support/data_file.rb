module DataFile
  def data_file(name)
    File.new(File.expand_path("../../data/#{name}", __FILE__))
  end
end

RSpec.configure do |rspec|
  rspec.include DataFile
end