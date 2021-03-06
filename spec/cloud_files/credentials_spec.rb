require 'spec_helper'

RSpec.describe CloudFiles::Credentials do
  let(:tmp_dir)         { Pathname.new(File.dirname(__FILE__)).join('..', '..', 'tmp') }
  let(:config_dir)      { tmp_dir.join('.cloud_files') }
  let(:credentials_dir) { config_dir.join('credentials') }

  before do
    FileUtils.rm_rf(config_dir)
    described_class.root_path = tmp_dir
    described_class.instance_variable_set(:@storage, nil)
  end

  after { FileUtils.rm_rf(config_dir) }

  describe ".directory" do
    it "returns the existing directory" do
      FileUtils.mkdir(config_dir)
      expect(described_class.directory).to eq(config_dir)
    end

    it "creates the directory if it does not exist" do
      expect { described_class.directory }.to change { File.exist?(config_dir) }.from(false).to(true)
    end
  end

  describe ".path" do
    it "returns the location of the credentials file" do
      expect(described_class.path).to eq(credentials_dir)
    end
  end

  describe "configured attributes" do
    it "returns nil when there is no configuration for the specified key" do
      subject = described_class.new('key')

       expect(subject.username).to be_nil
       expect(subject.api_key).to  be_nil
       expect(subject.region).to   be_nil
    end

    it "returns the set values" do
      subject = described_class.new('key', {
        :username => 'username',
        :api_key  => 'api_key',
        :region   => 'region'
      })

      expect(subject.username).to eq('username')
      expect(subject.api_key).to  eq('api_key')
      expect(subject.region).to   eq('region')
    end

    it "returns the stored value" do
      FileUtils.mkdir(config_dir)
      store = YAML::Store.new(credentials_dir)
      store.transaction do
        store['key'] = {'username' => 'username', 'api_key' => 'api_key', 'region' => 'region'}
      end

      subject = described_class.new('key')

      expect(subject.username).to eq('username')
      expect(subject.api_key).to  eq('api_key')
      expect(subject.region).to   eq('region')
    end
  end

  describe "#attributes=" do
    subject { described_class.new('alias') }

    it "does nothing when given an empty hash" do
      subject.attributes = {}

      expect(subject.username).to be_nil
      expect(subject.api_key).to  be_nil
      expect(subject.region).to   be_nil
    end

    it "raises an exception when given an invalid attribute" do
      expect { subject.attributes = {:bogon => true} }.to raise_error(NoMethodError)
    end

    it "sets the attributes" do
      subject.attributes = {:username => 'username', :api_key => 'api_key', :region => 'region'}

      expect(subject.username).to eq('username')
      expect(subject.api_key).to  eq('api_key')
      expect(subject.region).to   eq('region')
    end
  end

  describe "#save" do
    it "stores the specified credentials" do
      subject = described_class.new('alias', {
        :username => 'username',
        :api_key  => 'api_key',
        :region   => 'region'
      })

      subject.save

      storage    = YAML::Store.new(credentials_dir)
      attributes = storage.transaction { storage['alias'] }

      expect(attributes).to eq({
        'username' => 'username',
        'api_key'  => 'api_key',
        'region'   => 'region'
      })
    end

    it "overwrites existing credentials" do
      FileUtils.mkdir(config_dir)
      storage    = YAML::Store.new(credentials_dir)
      storage.transaction { storage['alias'] = {'username' => 'one', 'api_key' => 'one', 'region' => 'one'} }

      subject = described_class.new('alias', {
        :username => 'two',
        :api_key  => 'two',
        :region   => 'two'
      })

      subject.save

      attributes = storage.transaction { storage['alias'] }

      expect(attributes).to eq({
        'username' => 'two',
        'api_key'  => 'two',
        'region'   => 'two'
      })
    end
  end

  describe "#delete" do
    it "does nothing if the credentials file doesn't exist" do
      subject = described_class.new('alias')
      subject.delete
    end

    context "with an existing file" do
      let(:storage) do
        FileUtils.mkdir(config_dir)
        YAML::Store.new(credentials_dir)
      end

      before do
        storage.transaction { storage['other'] = {'key' => 'value'} }
      end

      it "does nothing if the key doesn't exist" do
        subject = described_class.new('alias')
        expect { subject.delete }.to_not change { File.read(credentials_dir) }
      end

      it "removes the key from the credentials file" do
        original_contents = File.read(credentials_dir)

        storage.transaction { storage['alias'] = {'other_key' => 'other_value'} }

        updated_contents = File.read(credentials_dir)

        subject = described_class.new('alias')
        expect { subject.delete }.to change { File.read(credentials_dir) }.from(updated_contents).to(original_contents)
      end
    end
  end

  describe "#exists?" do
    it "is false if the key doesn't exist" do
      subject = described_class.new('alias')
      expect(subject.exists?).to be(false)
    end

    it "is true if the key exists" do
      credentials = described_class.new('alias', {:username => 'u', :api_key => 'a', :region => 'r'})
      credentials.save

      subject = described_class.new('alias')
      expect(subject.exists?).to be(true)
    end
  end

end