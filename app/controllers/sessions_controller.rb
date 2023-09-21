# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    @title = 'Sign In'
    super
  end

  def create
    validated_nlm = Settings.current.umls && valid_nlm_user?
    if validated_nlm || Settings.current.umls == false
      super
    elsif Settings.current.umls && validated_nlm == false
      flash[:danger] = 'Could not verify NLM User Account.'
      redirect_to user_session_path
    end
  end

  protected

  def valid_nlm_user?
    # Try to grab a simple valueset to see if credentials are valid
    validate_nlm_user('https://vsac.nlm.nih.gov/vsac/svs/RetrieveValueSet?id=2.16.840.1.113762.1.4.1',
                      Settings.current.http_proxy,
                      params[:user][:umls_password])
  end

  def validate_nlm_user(nlm_url, proxy, apikey)
    RestClient.proxy = proxy
    begin
      nlm_result = RestClient::Request.execute(method: :get,
                                               url: nlm_url,
                                               user: '',
                                               password: apikey)
      nlm_result.code == 200
    rescue StandardError
      false
    end
  end
end
