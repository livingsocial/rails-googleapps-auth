class SessionsController < ActionController::Base
  protect_from_forgery

  cattr_accessor :start_result_spy
  cattr_accessor :conclude_result_spy

  def start
    self.class.start_result_spy = :success
    google_apps_authenticate "example.com", :conclude, [:email] do
      self.class.start_result_spy = :failure
    end
  end

  def conclude
    if(the_google = google_apps_handle_auth) && the_google.succeeded?
      self.class.conclude_result_spy = :success
    else
      self.class.conclude_result_spy = :failure
    end
  end
end
