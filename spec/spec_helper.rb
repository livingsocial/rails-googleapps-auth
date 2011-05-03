$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))

require "active_support"
require "action_controller"

require "googleapps_auth"

require "rspec/rails"

class SessionsController < ActionController::Base

  cattr_accessor :start_result_spy
  cattr_accessor :conclude_result_spy

  def start
    # succeed
    google_apps_authenticate "example.com", :conclude, [:email] do
      # failed
    end
  end

  def conclude
    if(the_google = google_apps_handle_auth) && the_google.succeeded?
    else
    end
  end

end

RSpec.configure do |config|
  config.mock_with :rspec
end

