module GoogleAppsAuth
  class Railtie < ::Rails::Railtie
    config.after_initialize do
      ActionController::Base.send :include, GoogleAppsAuth
    end
  end
end
