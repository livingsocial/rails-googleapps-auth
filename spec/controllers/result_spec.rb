require File.dirname(__FILE__) + "/../spec_helper"

describe GoogleAppsAuth::Result do

  describe "when inspecting its status propery" do

    it "should indicate if was successful" do
      GoogleAppsAuth::Result.new(:success).should be_succeeded
    end

    it "should indicate if was canceled" do
      GoogleAppsAuth::Result.new(:canceled).should be_canceled
    end

    it "should indicate if was failed" do
      GoogleAppsAuth::Result.new(:failed).should be_failed
    end
  end

  describe "when checking errors" do

    it "should return an error string if one was passed" do
      GoogleAppsAuth::Result.new(:failed, "U MAD?").error.should eql("U MAD?")
    end

    it "should return nil if nothing was passed" do
      GoogleAppsAuth::Result.new(:failed).error.should be_nil
    end
  end

  describe "when configuring arbitrary attributes" do

    it "should default an empty hash if nothing was passed" do
      GoogleAppsAuth::Result.new(:failed)[:name].should be_nil
    end

    it "should return an attribute via its keyname when passed" do
      GoogleAppsAuth::Result.new(:failed, nil, {:env => "development"})[:env].should eql("development")
    end

  end

end

