require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('users', 'roles')
  end

  test 'should get show' do
    Rails.application.config.action_mailer.smtp_settings = {
      address: Cypress::AppConfig['mailer_address'],
      port: Cypress::AppConfig['mailer_port'],
      domain: Cypress::AppConfig['mailer_domain'],
      user_name: Cypress::AppConfig['mailer_user_name'],
      password: Cypress::AppConfig['mailer_password'],
      authentication: Cypress::AppConfig['mailer_authentication']
    }
    for_each_logged_in_user([ADMIN]) do
      get :show
      assert_response :success
    end
  end
end
