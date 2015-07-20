module CloudFiles
  class Container
    def initialize(spec)
      @spec = spec
    end

    def alias_name
      components['alias']
    end

    def name
      components['container']
    end

    def valid_format?
      alias_name.present? && name.present?
    end

    def alias_exists?
      alias_name.present? && instance.exists?
    end

    def exists?
      alias_exists? && container.present?
    end

    def upload(file)
      file.readable? && container.files.create(:key => file.to_s, :body => file.read).present?
    end

    def create
      instance.create_container(name)
    end

    private

    def instance
      @instance ||= CloudFiles::Instance.new(alias_name)
    end

    def container
      @container ||= instance.find_container(name)
    end

    def components
      %r{^(?<alias>[\w_-]+)/(?<container>[\w_-]+)$}.match(@spec) || {}
    end

  end
end