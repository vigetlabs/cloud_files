require 'spec_helper'

RSpec.describe CloudFiles::Instance do
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
      before do
        allow(credentials).to receive(:exists?).and_return(true)
        allow(CloudFiles::Credentials).to receive(:new).with('alias').and_return(credentials)
      end

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