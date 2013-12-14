require 'spec_helper'

shared_examples "GuitarProTab" do |file_name|
  let(:subject) { described_class.new(data_file(file_name)) }
  it 'reads version' do
    subject.version.should_not be_nil
  end
  #it 'extends proper version module' do
  #  subject.singleton_class.ancestors.map(&:to_s).should include("GuitarTabs::GuitarPro::GP#{subject.version.major}")
  #end
  it 'reads info' do
    subject.info.title.should_not be_nil
  end
  it 'reads song' do
    pending "Broken"
    subject.should_receive(:read_info)
    subject.read_song
  end
end
