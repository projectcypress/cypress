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
    validate_nlm_user('https://utslogin.nlm.nih.gov/cas/v1/api-key',
                      Settings.current.http_proxy,
                      params[:user][:umls_password])
  end

  def validate_nlm_user(nlm_url, proxy, apikey)
    RestClient.proxy = proxy
    begin
      nlm_result = RestClient.post(nlm_url, apikey:)
      doc = Nokogiri::HTML(nlm_result.body)
      doc.search('title').text == '201 Created'
    rescue StandardError
      false
    end
  end
end
