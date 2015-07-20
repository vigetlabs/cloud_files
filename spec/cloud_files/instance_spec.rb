require 'spec_helper'

RSpec.describe CloudFiles::Instance do
  def stub_valid_credentials(credentials)
    allow(credentials).to receive(:exists?).and_return(true)
    allow(CloudFiles::Credentials).to receive(:new).with('alias').and_return(credentials)
  end

  let(:credentials) do
    CloudFiles::Credentials.new('alias', {
      :username => 'username',
      :api_key  => 'api_key',
      :region   => 'region'
    })
  end

  describe "#find_container" do
    subject { described_class.new('alias') }

    it "returns nil if the credentials are invalid" do
      allow(subject).to receive(:exists?).and_return(false)
      expect(subject.find_container('container')).to be_nil
    end

    context "with valid credentials" do
      before { stub_valid_credentials(credentials) }

      it "returns nil if the container can't be found" do
        directories = double.tap {|d| allow(d).to receive(:get).with('container').and_return(nil) }
        connection  = double(:directories => directories)

        allow(Fog::Storage::Rackspace).to receive(:new).and_return(connection)

        expect(subject.find_container('container')).to be_nil
      end

      it "returns the container" do
        directories = double.tap {|d| allow(d).to receive(:get).with('container').and_return('container') }
        connection  = double(:directories => directories)

        allow(Fog::Storage::Rackspace).to receive(:new).and_return(connection)

        expect(subject.find_container('container')).to eq('container')
      end
    end
  end

  describe "#create_container" do
    it "returns nil if the credentials are invalid" do
      subject = described_class.new('alias')
      allow(subject).to receive(:exists?).and_return(false)

      expect(subject.create_container('test')).to be_nil
    end

    context "with valid credentials" do
      before { stub_valid_credentials(credentials) }

      let(:container_name) { 'container-name' }
      let(:container)      { double(:container) }

      it "creates the container" do
        directories = double.tap {|d| expect(d).to receive(:create).with(:key => container_name).and_return(container) }
        connection  = double(:connection, :directories => directories)

        allow(Fog::Storage::Rackspace).to receive(:new).and_return(connection)

        subject = described_class.new('alias')
        subject.create_container(container_name)
      end

      it "returns true when successful" do
        directories = double.tap {|d| allow(d).to receive(:create).with(:key => container_name).and_return(container) }
        connection  = double(:connection, :directories => directories)

        allow(Fog::Storage::Rackspace).to receive(:new).and_return(connection)

        subject = described_class.new('alias')
        expect(subject.create_container(container_name)).to be(true)
      end

      it "returns false when unsuccessful" do
        pending "Determine what success / failure means for creating directories"
        fail
      end
    end
  end

  describe "#exists?" do
    it "is false if the credentials don't exist" do
      allow(credentials).to receive(:exists?).and_return(false)
      allow(CloudFiles::Credentials).to receive(:new).with('alias').and_return(credentials)

      subject = described_class.new('alias')
      expect(subject.exists?).to be(false)
    end

    it "is false if the credentials exist but are invalid" do
      allow(credentials).to receive(:exists?).and_return(true)
      allow(CloudFiles::Credentials).to receive(:new).with('alias').and_return(credentials)

      allow(Fog::Storage::Rackspace).to receive(:new).and_raise(Excon::Errors::Unauthorized, "unauthorized")

      subject = described_class.new('alias')
      expect(subject.exists?).to be(false)
    end

    it "is true if the credentials exist and are valid" do
      allow(credentials).to receive(:exists?).and_return(true)
      allow(CloudFiles::Credentials).to receive(:new).with('alias').and_return(credentials)

      allow(Fog::Storage::Rackspace).to receive(:new).and_return('connection')

      subject = described_class.new('alias')
      expect(subject.exists?).to be(true)
    end
  end

end