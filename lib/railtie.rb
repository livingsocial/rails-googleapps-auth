module GoogleAppsAuth
  module Rails
    class Railtie < ::Rails::Railtie
      config.after_initialize do
        ActionController::Base.send :include, GoogleAppsAuth
      end
    end
  end
end
