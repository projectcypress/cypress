require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('users', 'roles')
  end

  test 'should get show' do
    Rails.application.config.action_mailer.smtp_settings = {
      address: APP_CONFIG['mailer_address'],
      port: APP_CONFIG['mailer_port'],
      domain: APP_CONFIG['mailer_domain'],
      user_name: APP_CONFIG['mailer_user_name'],
      password: APP_CONFIG['mailer_password'],
      authentication: APP_CONFIG['mailer_authentication']
    }
    for_each_logged_in_user([ADMIN]) do
      get :show
      assert_response :success
    end
  end
end
