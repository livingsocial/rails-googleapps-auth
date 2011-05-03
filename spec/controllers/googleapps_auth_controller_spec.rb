require File.dirname(__FILE__) + "/../spec_helper"

describe SessionsController, :type => :controller do

  describe "when initiating an auth request" do

    describe "and no certfile is configured" do

      it "should raise" do
        GoogleAppsAuth.certificate_authority_file = nil

        lambda { get :start }.should raise_error(GoogleAppsAuth::CertificateAuthorityFileError)
      end

    end

  end

end
