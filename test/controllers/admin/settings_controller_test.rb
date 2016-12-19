require 'test_helper'

class Admin::SettingsControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('users', 'roles')
    @controller = Admin::SettingsController.new
  end

  test 'should successfully update yml' do
    orig_yml = File.read("#{Rails.root}/config/cypress.yml")
    begin
      for_each_logged_in_user([ADMIN]) do
        patch :update, banner_message: 'banner test', mailer_address: 'smtp.example.com', mailer_port: 3000, mailer_domain: 'example.com',
                       mailer_user_name: 'testuser', mailer_password: 'password123', mode: 'custom',
                       custom_options: { auto_approve: 'disable', ignore_roles: 'disable', default_role: 'admin', debug_features: 'disable' }
      end
      assert_equal 'banner test', Cypress::AppConfig['banner_message']
      assert_equal 'smtp.example.com', Rails.application.config.action_mailer.smtp_settings.address
      assert_equal 3000, Rails.application.config.action_mailer.smtp_settings.port
      assert_equal 'example.com', Rails.application.config.action_mailer.smtp_settings.domain
      assert_equal 'testuser', Rails.application.config.action_mailer.smtp_settings.user_name
      assert_equal 'password123', Rails.application.config.action_mailer.smtp_settings.password
      assert_equal 'Custom', @controller.application_mode
      assert_equal false, Cypress::AppConfig['auto_approve']
      assert_equal false, Cypress::AppConfig['ignore_roles']
      assert_equal :admin, Cypress::AppConfig['default_role']
      assert_equal false, Cypress::AppConfig['enable_debug_features']
    ensure
      File.open("#{Rails.root}/config/cypress.yml", 'w') { |file| file.puts orig_yml }
    end
  end
end
