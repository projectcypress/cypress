require 'test_helper'

class AdminControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('users', 'roles')
  end

  test 'should get show' do
    Rails.application.config.action_mailer.smtp_settings = {
      address: Settings[:mailer_address],
      port: Settings[:mailer_port],
      domain: Settings[:mailer_domain],
      user_name: Settings[:mailer_user_name],
      password: Settings[:mailer_password],
      authentication: Settings[:mailer_authentication]
    }
    for_each_logged_in_user([ADMIN]) do
      get :show
      assert_response :success
    end
  end
end
