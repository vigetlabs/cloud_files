module CloudFiles
  class CLI

    def initialize(args)
      @args = args
    end

    def run
      command ? command.run : puts(parser)
    end

    private

    def banner
      String.new.tap do |banner|
        banner << "\n" +
          "Usage: cf <command> [options]\n\n" +
          "Commands:\n\n#{command_descriptions}" +
          "\n\n"
      end
    end

    def command_descriptions
      CloudFiles::Commands.command_classes.map do |klass|
        sprintf('%12s: %s', klass.name, klass.description)
      end.join("\n")
    end

    def parser
      @parser ||= OptionParser.new do |parser|
        parser.banner = banner
      end
    end

    def command_name
      @command_name ||= @args.shift
    end

    def command
      if command_name.present?
        begin
          "CloudFiles::Commands::#{command_name.titleize}".constantize.new(@args)
        rescue NameError
          puts "Error: unrecognized subcommand: #{command_name}"
          exit 1
        end
      end
    end

  end
end