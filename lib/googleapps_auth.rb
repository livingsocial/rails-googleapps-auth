require "googleapps_auth/railtie" if defined?(Rails::Railtie)

require 'openid'
require 'openid/store/memory'
require 'openid/extensions/ax'

module GoogleAppsAuth
  ID_PREFIX = "https://www.google.com/accounts/o8/site-xrds?hd="
  XRDS_PREFIX = "https://www.google.com/accounts/o8/user-xrds?uri="
  AX_SCHEMAS = {
    :email => "http://schema.openid.net/contact/email",
    :firstname => "http://axschema.org/namePerson/first",
    :lastname => "http://axschema.org/namePerson/last",
    :language => "http://axschema.org/pref/language"
  }

  def self.certificate_authority_file=(path)
    OpenID.fetcher.ca_file = path
  end

  def self.certificate_authority_file?
    !! OpenID.fetcher.ca_file
  end

  def self.certificate_authority_file
    OpenID.fetcher.ca_file
  end

  class Result
    attr_reader :error
    def initialize(status, error=nil, attrs=nil)
      @status = status
      @error = error
      @attrs = attrs || {}
    end

    def [](attr)
      @attrs[attr]
    end

    def succeeded?
      @status == :success
    end

    def canceled?
      @status == :canceled
    end

    def failed?
      @status == :failed
    end
  end

  class CertificateAuthorityFileError < StandardError; end

  protected
  def google_apps_authenticate(appname, return_action = 'finish', get_attrs = nil)
    assert_certificate_authority_file_present!

    get_attrs ||= []
    begin
      oidreq = consumer.begin GoogleAppsAuth::ID_PREFIX + appname
      return_to = url_for :action => return_action, :only_path => false
      realm = request.protocol + request.host_with_port
      ax = OpenID::AX::FetchRequest.new
      get_attrs.each { |attr|
        ax.add OpenID::AX::AttrInfo.new(GoogleAppsAuth::AX_SCHEMAS[attr], attr.to_s, true)
      }
      oidreq.add_extension(ax)
      redirect_to oidreq.redirect_url(realm, return_to, false)
    rescue OpenID::OpenIDError => e
      Rails.logger.error "ERROR: #{e.inspect}" if defined?(Rails)

      if block_given?
        yield
      else
        flash[:notice] = "Discovery failed."
        redirect_to :action => 'index'
      end
    end
  end


  def google_apps_handle_auth
    assert_certificate_authority_file_present!

    current_url = url_for(:action => request.symbolized_path_parameters[:action], :only_path => false)
    parameters = params.reject { |k, v| request.symbolized_path_parameters[k.to_sym] }
    oidresp = consumer.complete(parameters, current_url)

    case oidresp.status
    when OpenID::Consumer::FAILURE
      GoogleAppsAuth::Result.new :failed, oidresp.message
    when OpenID::Consumer::CANCEL
      GoogleAppsAuth::Result.new :canceled, "Authentication canceled."
    when OpenID::Consumer::SUCCESS
      resp = OpenID::AX::FetchResponse.from_success_response(oidresp)
      attrs = {}
      GoogleAppsAuth::AX_SCHEMAS.each { |name,schema|
        attrs[name] = resp.data[schema] if not resp.data[schema].nil?
      }
      GoogleAppsAuth::Result.new :success, nil, attrs
    else
      GoogleAppsAuth::Result.new :failed, "Unknown error."
    end
  end

  def store
    OpenID::Store::Memory.new
  end

  def consumer
    @consumer ||= OpenID::Consumer.new(session, store)
  end

  def assert_certificate_authority_file_present!
    unless GoogleAppsAuth.certificate_authority_file?
      raise CertificateAuthorityFileError,
        "Configure a CA file through GoogleAppsAuth.certificate_authority_file="
    end

    unless File.exists?(GoogleAppsAuth.certificate_authority_file)
      raise CertificateAuthorityFileError,
        "GoogleAppsAuth.certificate_authority_file= is a non-existent file"
    end
  end
end

## TemplateURI's are not followed by the openid gem - so we have to trick it
class OpenID::Consumer::IdResHandler
  def verify_discovery_results
    oldid = @message.get_arg(OpenID::OPENID_NS, 'identity', nil)
    @message.set_arg(OpenID::OPENID_NS, 'identity', GoogleAppsAuth::XRDS_PREFIX + oldid)
    @message.set_arg(OpenID::OPENID_NS, 'claimed_id', GoogleAppsAuth::XRDS_PREFIX + oldid)
    verify_discovery_results_openid2
    @message.set_arg(OpenID::OPENID_NS, 'identity', oldid)
    @message.set_arg(OpenID::OPENID_NS, 'claimed_id', oldid)
  end
end
