module CloudFiles
  module Commands
    autoload :Common, 'cloud_files/commands/common'

    COMMAND_NAMES = [:configure, :upload]

    def self.command_classes
      @command_classes ||= []
    end

    COMMAND_NAMES.each do |command_name|
      class_name = command_name.to_s.titleize

      autoload class_name, "cloud_files/commands/#{command_name}"

      command_classes << self.const_get(class_name)
    end

  end
end