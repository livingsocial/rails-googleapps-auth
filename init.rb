require 'googleapps_auth'

config.gem 'memcache-client', :lib => 'memcache'

config.after_initialize do
  ActionController::Base.send :include, GoogleAppsAuth
end
