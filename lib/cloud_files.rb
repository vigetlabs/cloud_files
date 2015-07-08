require 'rubygems'
require 'bundler/setup'

require "cloud_files/version"

require 'yaml/store'

require 'active_support/core_ext/string'
require 'active_support/core_ext/module'

require 'fog'

module CloudFiles
  autoload :Instance,            'cloud_files/instance'
  autoload :Credentials,         'cloud_files/credentials'
  autoload :ContainerCollection, 'cloud_files/container_collection'
  autoload :Container,           'cloud_files/container'
  autoload :FileCollection,      'cloud_files/file_collection'
  autoload :File,                'cloud_files/file'
end
