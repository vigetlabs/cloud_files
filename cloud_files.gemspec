# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cloud_files/version'

Gem::Specification.new do |spec|
  spec.name          = "cloud_files"
  spec.version       = CloudFiles::VERSION
  spec.authors       = ["Patrick Reagan"]
  spec.email         = ["reaganpr@gmail.com"]

  spec.summary       = %q{Work with Rackspace cloudfiles}
  spec.homepage      = "http://viget.com/extend"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = ['cf']
  spec.require_paths = ['lib']

  spec.add_dependency "fog", "~> 1.32.0"
  spec.add_dependency "activesupport", "~> 4.2.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake",    "~> 10.0"
  spec.add_development_dependency "rspec",   "~> 3.2.0"
end