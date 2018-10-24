require 'test_helper'

module Admin
  class SettingsControllerTest < ActionController::TestCase
    setup do
      FactoryBot.create(:admin_user)
      @controller = Admin::SettingsController.new
    end

    test 'should successfully update settings' do
      for_each_logged_in_user([ADMIN]) do
        patch :update, params: { banner_message: 'banner test', warning_message: 'banner warning test', mailer_address: 'smtp.example.com', mailer_port: 3000, mailer_domain: 'example.com', mailer_user_name: 'testuser', mailer_password: 'password123', mode: 'custom', custom_options: { auto_approve: 'disable', ignore_roles: 'disable', default_role: 'admin', debug_features: 'disable' } }
      end
      assert_equal 'banner test', Settings.current.banner_message
      assert_equal 'banner warning test', Settings.current.warning_message
      assert_equal 'smtp.example.com', Settings.current.mailer_address
      assert_equal 3000, Settings.current.mailer_port
      assert_equal 'example.com', Settings.current.mailer_domain
      assert_equal 'testuser', Settings.current.mailer_user_name
      assert_equal 'password123', Settings.current.mailer_password
      assert_equal 'Custom', Settings.current.application_mode
      assert_equal false, Settings.current.auto_approve
      assert_equal false, Settings.current.ignore_roles
      assert_equal :admin, Settings.current.default_role
      assert_equal false, Settings.current.enable_debug_features
    end
  end
end
