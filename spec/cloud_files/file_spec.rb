require 'spec_helper'

describe CloudFiles::File do

  describe "#readable?" do
    it "is false if the file doesn't exist" do
      subject = described_class.new(fixture_path.join('bogus.txt'))
      expect(subject.readable?).to be(false)
    end

    it "is false if the file is a directory" do
      subject = described_class.new(fixture_path)
      expect(subject.readable?).to be(false)
    end

    it "is true if the regular file exists" do
      subject = described_class.new(fixture_path.join('testfile.txt'))
      expect(subject.readable?).to be(true)
    end
  end

  describe "#read" do
    it "returns nil when the file isn't readable" do
      subject = described_class.new(fixture_path) # Can't read a dir
      expect(subject.read).to be_nil
    end

    it "returns the file's contents if it is readable" do
      subject = described_class.new(fixture_path.join('testfile.txt'))
      expect(subject.read).to eq('content')
    end
  end

  describe "#to_s" do
    it "returns the file's path as a string" do
      subject = described_class.new(fixture_path.join('testfile.txt'))
      expect(subject.to_s).to eq("#{fixture_path}/testfile.txt")
    end
  end

end