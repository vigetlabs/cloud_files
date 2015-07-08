require 'spec_helper'

RSpec.describe CloudFiles::FileCollection do

  describe "#files" do
    it "is empty when there are no files" do
      subject = described_class.new([])
      expect(subject.files).to eq([])
    end

    it "returns a collection of matched files" do
      allow(CloudFiles::File).to receive(:new).with(Pathname.new("#{fixture_path}/testfile.txt")).and_return('file')

      subject = described_class.new([fixture_path.join('testfile.txt')])
      expect(subject.files).to eq(['file'])
    end
  end

  describe "#each" do
    it "iterates over the files" do
      subject = described_class.new([fixture_path.join('testfile.txt')])

      contents = []
      subject.each {|f| contents << f.read }

      expect(contents).to eq(['content'])
    end
  end

  describe "#length" do
    it "returns the count of the number of files" do
      subject = described_class.new(double)
      allow(subject).to receive(:files).and_return([double, double])

      expect(subject.length).to eq(2)
    end
  end

end
