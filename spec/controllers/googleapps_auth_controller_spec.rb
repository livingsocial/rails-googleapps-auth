require File.dirname(__FILE__) + "/../spec_helper"

describe SessionsController, :type => :controller do

  let :certfile do
    File.dirname(__FILE__) + "/../cacert.pem"
  end

  describe "when configuring the plugin" do

    describe "and no certfile is configured" do

      it "should raise" do
        GoogleAppsAuth.certificate_authority_file = nil

        lambda { get :start }.should raise_error(GoogleAppsAuth::CertificateAuthorityFileError)
      end

    end

    describe "and an incorrect path is passed" do
      it "should raise" do
       GoogleAppsAuth.certificate_authority_file = "daksjdkasjkdjsakldjksa"

       lambda { get :start }.should raise_error(GoogleAppsAuth::CertificateAuthorityFileError)
      end
    end

  end

  describe "in the auth sequence" do

    before :all do
      GoogleAppsAuth.certificate_authority_file = certfile
    end

    describe "when beginning" do

      it "should redirect away to google when given the correct google apps domain" do
        check_id_request = double(:check_id_request, {:add_extension => nil, :redirect_url => "http://google.com/a/example.com"})
        controller.__send__(:consumer).stub!(:begin).and_return(check_id_request)

        get :start
        response.should redirect_to("http://google.com/a/example.com")
      end

    end

    describe "when completing the auth sequence from a correct google apps domain" do

      it "should return a success result when " do
        status_response = double(:status_response, {:status => OpenID::Consumer::SUCCESS})
        controller.__send__(:consumer).stub!(:complete).and_return(status_response)

        oid_response = double(:oid_response, {:data => {}})
        OpenID::AX::FetchResponse.stub!(:from_success_response).and_return(oid_response)

        get :conclude

        response.should be_success
      end

    end

  end

end
