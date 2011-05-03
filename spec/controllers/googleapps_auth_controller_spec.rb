require File.dirname(__FILE__) + "/../spec_helper"

describe SessionsController do

  describe "when initiating an auth request" do

    describe "and no certfile is configured" do

      it "should raise and issue a 500 status" do
        GoogleAppsAuth.certificate_authority_file = nil

        get :start
        response.should be_failure
      end

    end

  end

end
