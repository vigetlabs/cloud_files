require 'spec_helper'
require 'fog/rackspace/models/storage/file'

RSpec.describe CloudFiles::Container do

  describe "#alias_name" do
    it "is nil when the spec is nil" do
      subject = described_class.new(nil)
      expect(subject.alias_name).to be_nil
    end

    it "is nil when the spec is invalid" do
      subject = described_class.new('invalid')
      expect(subject.alias_name).to be_nil
    end

    it "knows the value when the spec is valid" do
      subject = described_class.new('alias/container')
      expect(subject.alias_name).to eq('alias')
    end
  end

  describe "#name" do
    it "is nil when the spec is nil" do
      subject = described_class.new(nil)
      expect(subject.name).to be_nil
    end

    it "is nil when the spec is invalid" do
      subject = described_class.new('invalid')
      expect(subject.name).to be_nil
    end

    it "knows the value when the spec is valid" do
      subject = described_class.new('alias/container')
      expect(subject.name).to eq('container')
    end
  end

  describe "#valid_format?" do
    it "is false when the spec is nil" do
      subject = described_class.new(nil)
      expect(subject.valid_format?).to be(false)
    end

    it "is false when there is only an alias" do
      subject = described_class.new('alias')
      expect(subject.valid_format?).to be(false)
    end

    it "is true when there is an alias and container" do
      subject = described_class.new('alias/container')
      expect(subject.valid_format?).to be(true)
    end
  end

  describe "#alias_exists?" do
    it "is false if the spec is invalid" do
      subject = described_class.new('alias')
      expect(subject.alias_exists?).to be(false)
    end

    it "is false if the alias isn't configured" do
      cloudfiles_instance = double(:exists? => false)
      allow(CloudFiles::Instance).to receive(:new).with('alias').and_return(cloudfiles_instance)

      subject = described_class.new('alias/container')
      expect(subject.alias_exists?).to be(false)
    end

    it "is true if the alias is configured" do
      cloudfiles_instance = double(:exists? => true)
      allow(CloudFiles::Instance).to receive(:new).with('alias').and_return(cloudfiles_instance)

      subject = described_class.new('alias/container')
      expect(subject.alias_exists?).to be(true)
    end
  end

  describe "#exists?" do
    it "is false if the spec is invalid" do
      subject = described_class.new('alias')
      expect(subject.exists?).to be(false)
    end

    it "is false if the alias doesn't exist" do
      subject = described_class.new('alias/container')
      allow(subject).to receive(:alias_exists?).and_return(false)

      expect(subject.exists?).to be(false)
    end

    it "is false if the container doesn't exist" do
      instance = double(:exists? => true).tap do |instance|
        allow(instance).to receive(:find_container).with('missing-container').and_return(nil)
      end

      allow(CloudFiles::Instance).to receive(:new).with('alias').and_return(instance)

      subject = described_class.new('alias/missing-container')
      expect(subject.exists?).to be(false)
    end

    it "is true if the container exists" do
      container = double()

      instance = double(:exists? => true).tap do |instance|
        allow(instance).to receive(:find_container).with('existing-container').and_return(container)
      end

      allow(CloudFiles::Instance).to receive(:new).with('alias').and_return(instance)

      subject = described_class.new('alias/existing-container')
      expect(subject.exists?).to be(true)
    end
  end

  describe "#upload" do
    let(:uploaded_file) { Fog::Storage::Rackspace::File.new }
    let(:file_path)     { fixture_path.join('testfile.txt') }
    let(:file)          { CloudFiles::File.new(file_path) }

    it "uploads a file to the matched container" do
      files     = double.tap {|f| expect(f).to receive(:create).with(:key => file_path.to_s, :body => 'content').and_return(uploaded_file) }
      container = double(:files => files)

      instance = double(:exists? => true).tap do |instance|
        allow(instance).to receive(:find_container).with('existing-container').and_return(container)
      end

      allow(CloudFiles::Instance).to receive(:new).with('alias').and_return(instance)

      subject = described_class.new('alias/existing-container')
      subject.upload(file)
    end

    it "returns true when successful" do
      files     = double.tap {|f| allow(f).to receive(:create).and_return(uploaded_file) }
      container = double(:files => files)

      instance = double(:exists? => true).tap do |instance|
        allow(instance).to receive(:find_container).with('existing-container').and_return(container)
      end

      allow(CloudFiles::Instance).to receive(:new).with('alias').and_return(instance)

      subject = described_class.new('alias/existing-container')
      expect(subject.upload(file)).to be(true)
    end

    it "returns false when not successful" do
      pending "Determine what success / failure means for uploading files (e.g. remote content_length != local content_length?)"
      fail
    end
  end

end