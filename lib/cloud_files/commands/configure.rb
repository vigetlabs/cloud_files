module CloudFiles
  module Commands
    class Configure
      include Common

      description 'Configure credentials for the specified alias'

      def run
        parser.parse!(@arguments)
        provided_arguments

        validate && store_credentials
      end

      private

      def required_arguments
        [:alias]
      end

      def store_credentials
        attributes = CloudFiles::Credentials::ATTRIBUTES.inject({}) do |mapping, key|
          print " * #{key}: "
          mapping.merge!(key => gets.chomp)
        end

        CloudFiles::Credentials.store(provided_arguments[:alias], attributes)
      end

    end
  end
end