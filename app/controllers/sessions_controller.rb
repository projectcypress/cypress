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
      flash[:danger] = 'Could not Validate NLM User Account'
      redirect_to user_session_path
    end
  end

  protected

  def valid_nlm_user?
    validate_nlm_user('https://uts-ws.nlm.nih.gov/restful/isValidUMLSUser',
                      Settings.current.http_proxy,
                      Settings.current.umls_license,
                      params[:user][:umls_username],
                      params[:user][:umls_password])
  end

  def validate_nlm_user(nlm_url, proxy, nlm_license_code, nlm_user, nlm_password)
    RestClient.proxy = proxy
    nlmResult = RestClient.post nlm_url, user: nlm_user, password: nlm_password, licenseCode: nlm_license_code
    doc = Nokogiri::HTML(nlmResult.body)
    doc.search('result').text == 'true'
  end
end
