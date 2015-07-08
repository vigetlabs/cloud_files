module CloudFiles
  module Commands
    class Upload
      include Common

      description 'Upload files to the specified alias & container'

      def run
        parser.parse!(@arguments)

        provided_arguments.merge!(:container => @arguments.pop)
        provided_arguments.merge!(:files     => @arguments)

        validate && upload_files && puts(stats.inspect)
      end

      private

      def stats
        @stats ||= {:success => 0, :failure => 0}
      end

      def provided_arguments
        @provided_arguments ||= {}
      end

      def required_arguments
        [:files, :container]
      end

      def validate
        super && validate_container
      end

      def validate_container
        if !container.valid_format?
          display_error_message("container must be in the format of <alias>/<container-name>")
          false
        elsif !container.alias_exists?
          display_error_message("alias '#{container.alias_name}' does not exist. Run `cf configure #{container.alias_name}` to add")
          false
        elsif !container.exists?
          display_error_message("container '#{container.name}' does not exist for alias '#{container.alias_name}'")
          false
        else
          true
        end
      end

      def container
        @container ||= CloudFiles::Container.new(provided_arguments[:container])
      end

      def files
        @files ||= CloudFiles::FileCollection.new(provided_arguments[:files])
      end

      def upload_files
        puts "Uploading files to '#{provided_arguments[:container]}':"

        files.each do |file|
          print " * Sending '#{file.to_s}' ... "
          if container.upload(file)
            stats[:success] += 1
            puts "success."
          else
            stats[:failure] += 1
            puts "failure."
          end
        end

        puts "Successfully uploaded #{stats[:success]}/#{files.length} files, #{stats[:failure]} errors."
      end

    end
  end
end