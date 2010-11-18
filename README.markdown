# Rails-GoogleApps-Auth
rails-googleapps-auth is a Rails plugin for OpenID auth against Google apps for your domain accounts.  There are a few unique issues
when dealing with authenticating against Google's Apps-For-Your-Domain accounts, which is why this plugin was created (instead of using 
[a more general plugin](https://github.com/rails/open_id_authentication)).  

# Usage
## Installation 
First, install https://github.com/openid/ruby-openid:
       gem install ruby-openid


Then, checkout this repo into your vendors/plugins dir:
      git clone git://github.com/livingsocial/rails-googleapps-auth.git vendors/plugins/rails-googleapps-auth


## Authenticating Users
Create a new controller.
    class AuthController < ApplicationController
        def login
            # user will immediately be redirected to google to log in.
            # args are 1) your domain, 2) your "finish" controller action, and 
            # 3) any required ax params (email/firstname/lastname/language)
            google_apps_authenticate "hungrymachine.com", 'finish', [:email]
        end

        def finish
            response = google_apps_handle_auth
            if response.failed? or response.canceled?
                flash[:notice] = "Could not authenticate: #{response.error}"
            else   
                # start a session, log user in
                session[:user] = response[:email]
                flash[:notice] = "Thanks for logging in, #{response[:email]}"
            end
            redirect_to :root_url
        end
    end

To log users in, just redirect them to your controller's **login** action.  Additionally, you will need to 
add routes for your two actions in your *config/routes.rb* file:
     map.resources :auth, :collection => { :login => :get, :finish => :get }

Additionally, a memory store is used by default, but if you will have many users authenticating you should use a different 
[OpenID::Store](https://github.com/openid/ruby-openid/tree/master/lib/openid/store/) by adding a *store* protected method to your controller:

    require 'openid/store/memory' # or 'openid/store/filesystem'

    class AuthController < ApplicationController

        ...

	protected
        def store
            OpenID::Store::Memcache.new(MemCache.new('localhost:11211'))
            # or OpenID::Store::Filesystem.new(Rails.root.join('tmp/openids'))
        end
    end


# Further Reading
 * [Google's docs on OpenID discovery for hosted domains](http://groups.google.com/group/google-federated-login-api/web/openid-discovery-for-hosted-domains)
 * [Google's docs on OpenID for general accounts](http://code.google.com/apis/accounts/docs/OpenID.html)
 * [ruby-openid gem](https://github.com/openid/ruby-openid)


# Alternative
An alternative to this module is the full [open_id_authentication plugin](https://github.com/rails/open_id_authentication), which may
be useful if you plan to authenticate against other identity providers than Google.

