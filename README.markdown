# Rails-GoogleApps-Auth
rails-googleapps-auth is a Rails plugin for OpenID auth against Google apps for your domain accounts.  There are a few unique issues
when dealing with authenticating against Google's Apps-For-Your-Domain accounts, which is why this plugin was created (instead of using
[a more general plugin](https://github.com/rails/open_id_authentication)).

# Usage
## Installation

### Gem

    gem "googleapps-auth", "0.1.0", :require => "googleapps_auth"

## Configuration
The path to a certificate file _must_ be configured before you start making requests to Google Apps. Due to
short comings of net/https, the default behavior is to silently fallback to VERIFY_NONE when faced with a ssl cert.

This is bad for many reasons but most notably, it can fall prey to man-in-the middle attacks.

The following line in a rails initializer will enable the plugin for use:

    GoogleAppsAuth.certificate_authority_file = File.join(::Rails.root, "file.pem")

Otherwise the authetication methods will raise GoogleAppsAuth::CertificateAuthorityFileError errors.

To set your Google Apps domain for all instances at initialization, rather than at call time, use:

    GoogleAppsAuth.default_domain = "example.com"

If you do not specify an Apps domain either via default_domain, or by the
:domain argument to google_apps_auth_begin, you'll be prompted by Google to
select which of your accounts to sign in with. This will allow users to log
into your Rails app using either their Google account or ANY Google Apps domain
account.

## Authenticating Users
Create a new controller.

    class AuthController < ApplicationController
        def login
            # User will immediately be redirected to Google to log in, and redirected back to the 'finish' action when done.

	    # Override defaults:
            google_apps_auth_begin :domain => "example.com", :return_action => 'finish', :attrs => [:email]

            # Or use no args at all (domain defaults to nil, return_action defaults to 'finish')
            # google_apps_auth_begin
        end

	def logout
	    reset_session
	    redirect_to :back
	end

        def finish
            response = google_apps_auth_finish
            if response.failed? or response.canceled?
                flash[:notice] = "Could not authenticate: #{response.error}"
            else
                # start a session, log user in.  AX values are arrays, get first.
                session[:user] = response[:email].first
                flash[:notice] = "Thanks for logging in, #{response[:email].first}"
            end
            redirect_to :back
        end
    end

To log users in, just redirect them to your controller's **login** action.  Additionally, you will need to
add routes for your two actions in your *config/routes.rb* file:

    resources :auth do
      collection do
        get 'login'
        get 'logout'
        get 'finish'
      end
    end

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

##Requiring Authentication in Controllers
To require that a user is authentication in order to perform certain actions, add the following helpers to ApplicationController:

    class ApplicationController < ActionController::Base
    
    ...
    
        def login_required
            if session[:user]
                return true
            end
            flash[:warning] = 'Login required.'
            session[:return_to] = request.fullpath
            redirect_to :controller => "auth", :action => "login"
            return false
        end

        def current_user
            session[:user]
        end
    end
    
Then at the top of each controller, specify the actions you wish to protect -- pick just one of the following *before_filter* for each controller:

    class YourController < ApplicationController
        # Protect every action in this controller
        before_filter :login_required
        
        # Protect just these actions
        before_filter :login_required, :only => [:monkeywith]
        
        # Protect everything else, but allow these to be unauthenticated
        before_filter :login_required, :except => [:justlooking]
    end

# Further Reading
 * [Google's docs on OpenID discovery for hosted domains](http://groups.google.com/group/google-federated-login-api/web/openid-discovery-for-hosted-domains)
 * [Google's docs on OpenID for general accounts](http://code.google.com/apis/accounts/docs/OpenID.html)
 * [ruby-openid gem](https://github.com/openid/ruby-openid)


# Alternative
An alternative to this module is the full [open_id_authentication plugin](https://github.com/rails/open_id_authentication), which may
be useful if you plan to authenticate against other identity providers than Google.

