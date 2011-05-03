$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))

require "active_support"
require "action_controller"

require "googleapps_auth"

require "rspec/rails"

RSpec.configure do |config|
  config.mock_with :rspec
end

