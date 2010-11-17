# Rails-GoogleApps-Auth
rails-googleapps-auth is a Rails plugin for OpenID auth against Google apps for your domain accounts.

# Usage
## Installation 
First, install https://github.com/openid/ruby-openid :
{% highlight bash %}
gem install openid
{% endhighlight %}

Then, checkout this repo into your vendors/plugins dir:
{% highlight bash %}
git clone git://github.com/livingsocial/rails-googleapps-auth.git vendors/plugins/rails-googleapps-auth
{% endhighlight %}

## Authenticating Users
Create a new controller.
{% highlight ruby %}
class OpenidController < ApplicationController
  def login
    # user will immediately be redirected to google to log in
    google_apps_authenticate "hungrymachine.com", 'finish', [:email]
  end

  def finish
    response = google_apps_handle_auth
    if response.failed? or response.canceled?
      render :text => response.error
    else
      # start a session, log user in
      render :text => "Hello, #{response[:email]}"
    end
  end
end
{% endhighlight %}


# Further Reading
http://groups.google.com/group/google-federated-login-api/web/openid-discovery-for-hosted-domains
http://code.google.com/apis/accounts/docs/OpenID.html

# Alternative
https://github.com/rails/open_id_authentication
