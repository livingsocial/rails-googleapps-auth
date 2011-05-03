$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib")))

require "action_controller/railtie"

module GoogleAppsAuth
  class Application < ::Rails::Application; end
end

GoogleAppsAuth::Application.initialize!

GoogleAppsAuth::Application.routes.draw do
  resource :sessions, :except => :all do
    get :start
    get :conclude
  end
end

require "googleapps_auth"

require File.dirname(__FILE__) + "/resources/sessions_controller"

require "rspec/rails"

RSpec.configure do |config|
  config.mock_with :rspec
  config.before(:each, :behaviour_type => :controller) do
    rescue_action_in_public!
  end
end

