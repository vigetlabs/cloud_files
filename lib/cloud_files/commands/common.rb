module CloudFiles
  module Commands
    module Common

      def self.included(other)
        other.extend(ClassMethods)
      end

      module ClassMethods
        def name
          self.to_s.demodulize.downcase
        end

        def description(description = nil)
          @description ||= description
        end
      end

      def initialize(arguments)
        @arguments = arguments
      end

      private

      def usage
        argument_spec = required_arguments.map {|a| "<#{format_argument(a)}>" }.join(' ')
        "Usage: cf #{self.class.name} #{argument_spec} [options]".squeeze(' ')
      end

      def options
        @options ||= {}
      end

      def parser
        @parser ||= OptionParser.new do |parser|
          parser.banner = usage

          parser.separator ""
          parser.separator self.class.description

          parser.separator ""
          parser.separator "Available Options:"

          yield(parser) if block_given?

          parser.on_tail('--help', 'Show help information') do
            puts parser
            exit
          end
        end
      end

      def required_arguments
        []
      end

      def provided_arguments
        @provided_arguments ||= required_arguments.inject({}) do |mapping, arg|
          mapping.merge(arg => @arguments.shift)
        end
      end

      def missing_arguments
        provided_arguments.select {|k,v| v.blank? }.keys.map {|a| format_argument(a) }
      end

      def display_error_message(message)
        puts "ERROR: #{message}"
        puts
        puts parser
      end

      def validate
        if missing_arguments.any?
          display_error_message("missing argument(s): #{missing_arguments.map {|a| "'#{a}'"}.join(', ')}")
          false
        else
          true
        end
      end

      def format_argument(argument_name)
        argument_name.to_s.sub('_', '-')
      end

    end
  end
end