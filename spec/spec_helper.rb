$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'cloud_files'

module FixtureHelper
  def fixture_path
    Pathname.new(File.expand_path('../fixtures', __FILE__))
  end
end

RSpec.configure do |config|
  config.include FixtureHelper
end