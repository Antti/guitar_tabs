require 'spec_helper'

describe GuitarTabs::GuitarPro, 'gp5' do
  it_behaves_like 'GuitarPro', 'amorphis_on_rich_and_poor.gp5'
  let(:subject) { described_class.new(data_file('amorphis_on_rich_and_poor.gp5')) }
  describe '#read_info' do
    #TODO: Move this
    before do 
      subject.read_info
    end
    its(:title){ should eq("On Rich and Poor") }
    its(:artist){ should eq("Amorphis") }
    its(:subtitle){ should eq("") }
    its(:album) { should eq("elegy") }
    its(:author){ should eq("Amorphis") }
  end
end
