class SessionsController < ActionController::Base
  protect_from_forgery

  def start
    google_apps_authenticate "example.com", :conclude, [:email] do
      render :status => 500, :text => ""
    end
  end

  def conclude
    if(the_google = google_apps_handle_auth) && the_google.succeeded?
      render :status => 200, :text => ""
    else
      render :status => 500, :text => ""
    end
  end
end
