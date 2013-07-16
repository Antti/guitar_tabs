require 'spec_helper'

shared_examples "GuitarPro" do |file_name|
  let(:gp_file) { described_class.new(data_file(file_name)) }
  it 'reads version' do
    gp_file.version.should_not be_nil
  end
  it 'extends proper version module' do
    gp_file.singleton_class.ancestors.map(&:to_s).should include("GuitarTabs::GuitarPro::GP#{gp_file.version.major}")
  end
  it 'reads song' do
    pending "Broken"
    gp_file.should_receive(:read_info)
    gp_file.read_song
  end
end
