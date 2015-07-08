module CloudFiles
  class Credentials
    ATTRIBUTES = [:username, :api_key, :region]

    attr_writer *ATTRIBUTES

    def self.root_path=(path)
      @root_path = path
    end

    def self.root_path
      @root_path || ENV['HOME']
    end

    def self.store(key, attributes = {})
      new(key, attributes).save
    end

    def self.directory
      Pathname.new(root_path).join('.cloud_files').tap do |path|
        path.mkdir unless path.exist?
      end
    end

    def self.path
      directory.join('credentials')
    end

    def initialize(key, attributes = {})
      @key = key
      attributes.map {|k, v| send("#{k}=", v) }
    end

    def exists?
      storage.transaction { storage[@key.to_s].present? }
    end

    def username
      @username ||= read['username']
    end

    def api_key
      @api_key ||= read['api_key']
    end

    def region
      @region ||= read['region']
    end

    def save
      storage.transaction do
        storage[@key] = {
          'username' => username,
          'api_key'  => api_key,
          'region'   => region
        }
      end
    end

    private

    def self.storage
      @storage ||= YAML::Store.new(path)
    end

    def read
      @data ||= storage.transaction { storage[@key] } || {}
    end

    def storage
      self.class.storage
    end

  end
end