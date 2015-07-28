module CloudFiles
  module Commands
    class Configure
      include Common

      description 'Configure credentials for the specified alias'

      def run
        parser.parse!(@arguments)
        provided_arguments

        validate && update_credentials
      end

      private

      def delete?
        options.fetch(:delete, false)
      end

      def update_credentials
        delete? ? delete_credentials : store_credentials
      end

      def parser
        super do |parser|
          parser.on('-d', '--delete', 'Delete the specfied alias from the credentials file') do
            options.merge!(:delete => true)
          end
        end
      end

      def required_arguments
        [:alias]
      end

      def delete_credentials
        credentials.delete
      end

      def store_credentials
        attributes = CloudFiles::Credentials::ATTRIBUTES.inject({}) do |mapping, key|
          print " * #{key}: "
          mapping.merge!(key => gets.chomp)
        end

        credentials.attributes = attributes
        credentials.save
      end

      def credentials
        @credentials ||= CloudFiles::Credentials.new(provided_arguments[:alias])
      end

    end
  end
end