config.gem "ruby-openid", :version => "2.1.8", :lib => "openid"

require 'googleapps_auth'

config.after_initialize do
  ActionController::Base.send :include, GoogleAppsAuth
end
