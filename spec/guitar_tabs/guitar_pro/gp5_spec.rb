require 'spec_helper'

describe GuitarTabs::GuitarPro, 'gp5' do
  it_behaves_like 'GuitarProTab', 'amorphis_on_rich_and_poor.gp5'
  let(:file_name){'amorphis_on_rich_and_poor.gp5'}
  let(:subject) { described_class.new(data_file(file_name)) }
  describe '#read_info' do
    subject{described_class.new(data_file(file_name)).info}
    its(:title){ should eq("On Rich and Poor") }
    its(:artist){ should eq("Amorphis") }
    its(:subtitle){ should eq("") }
    its(:album) { should eq("elegy") }
    its(:author){ should eq("Amorphis") }
  end
end
