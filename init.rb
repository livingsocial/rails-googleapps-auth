require 'googleapps_auth'

config.gem "ruby-openid", :lib => "2.1.8"

config.after_initialize do
  ActionController::Base.send :include, GoogleAppsAuth
end
