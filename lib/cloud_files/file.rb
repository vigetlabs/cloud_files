module CloudFiles
  class File
    delegate :to_s, :to => :file

    def initialize(filename)
      @filename = filename
    end

    def readable?
      file.exist? && file.file?
    end

    def read
      file.read if readable?
    end

    private

    def file
      @file ||= Pathname.new(@filename)
    end

  end
end