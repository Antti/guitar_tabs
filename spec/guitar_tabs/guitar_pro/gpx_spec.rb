require 'spec_helper'


describe GuitarTabs::GuitarPro, 'gpx' do
  it_behaves_like 'GuitarProTab', 'hey_you_6.gpx'
  let(:file_name){'hey_you_6.gpx'}
  let(:subject) { described_class.new(data_file(file_name)) }
  describe '#read_info' do
    its(:title){ should eq("On Rich and Poor") }
    its(:artist){ should eq("Amorphis") }
    its(:subtitle){ should eq("") }
    its(:album) { should eq("elegy") }
    its(:author){ should eq("Amorphis") }
  end
end
