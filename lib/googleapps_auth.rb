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

  class Result
    attr_reader :error
    def initialize(status, error=nil, attrs=nil)
      @status = status
      @error = error
      @attrs = attrs
      @attrs ||= {}
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
 

  protected
  def google_apps_authenticate(appname, return_action = 'finish', get_attrs = nil)
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
      flash[:notice] = "Discovery failed."
      redirect_to :action => 'index'
    end
  end


  def google_apps_handle_auth
    current_url = url_for(:action => request.path_parameters['action'], :only_path => false)
    parameters = params.reject{ |k,v| request.path_parameters[k] }
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


  private
  def consumer
    @@store ||= OpenID::Store::Memory.new
    @consumer ||= OpenID::Consumer.new(session, @@store) 
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
 
end
