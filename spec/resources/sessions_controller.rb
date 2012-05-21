class SessionsController < ActionController::Base
  protect_from_forgery

  def start
    ## google_apps_auth_begin :return_action => :conclude, :attrs => [:email] do
    google_apps_auth_begin :domain => "example.com", :return_action => :conclude, :attrs => [:email] do
      render :status => 500, :text => ""
    end
  end

  def conclude
    if(the_google = google_apps_auth_finish) && the_google.succeeded?
      render :status => 200, :text => ""
    else
      render :status => 500, :text => ""
    end
  end
end
