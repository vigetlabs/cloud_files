module CloudFiles
  class FileCollection
    include Enumerable

    delegate :each, :length, :to => :files

    def initialize(filenames)
      @filenames = filenames
    end

    def files
      @files ||= @filenames.map {|f| File.new(f) }
    end

  end
end