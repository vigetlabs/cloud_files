module CloudFiles
  class Instance

    def initialize(key)
      @key = key
    end

    def find_container(name)
      exists? ? connection.directories.get(name) : nil
    end

    def create_container(name)
      exists? ? connection.directories.create(:key => name).present? : nil
    end

    def exists?
      credentials.exists? && connection.present?
    end

    private

    def credentials
      @configuration ||= Credentials.new(@key)
    end

    def connection
      @connection ||= begin
        Fog::Storage::Rackspace.new({
          :rackspace_username => credentials.username,
          :rackspace_api_key  => credentials.api_key,
          :rackspace_region   => credentials.region
        })
      rescue Excon::Errors::Error
        nil
      end
    end

  end
end