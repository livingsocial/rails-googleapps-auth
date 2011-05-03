require File.dirname(__FILE__) + "/../spec_helper"

describe GoogleAppsAuth do

  let :ca_file do
    File.join(File.dirname(__FILE__), "..", "cacert.pem")
  end

  describe "when setting the certificate_authority_file property" do

    it "should know if its value was set" do
      GoogleAppsAuth.certificate_authority_file = ca_file
      GoogleAppsAuth.should be_certificate_authority_file
    end

    it "should set the underlying openid ca_file value" do
      OpenID.fetcher.should_receive(:ca_file=).with(ca_file)
      GoogleAppsAuth.certificate_authority_file = ca_file
    end

    it "should know its value" do
      GoogleAppsAuth.certificate_authority_file = ca_file
      GoogleAppsAuth.certificate_authority_file.should eql(ca_file)
    end
  end

  describe "when not setting the certificate_authority_file property" do

    it "should know that its value was not set" do
      GoogleAppsAuth.certificate_authority_file = nil
      GoogleAppsAuth.should_not be_certificate_authority_file
    end

    it "should set the underlying openid ca_file value" do
      OpenID.fetcher.should_receive(:ca_file=).with(nil)
      GoogleAppsAuth.certificate_authority_file = nil
    end

    it "should know its value is nil" do
      GoogleAppsAuth.certificate_authority_file = nil
      GoogleAppsAuth.certificate_authority_file.should be_nil
    end
  end

end

