require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  setup do
    collection_fixtures('users', 'roles')
    @controller = Admin::SettingsController.new
  end

  test 'should successfully update yml' do
    orig_yml = File.read("#{Rails.root}/config/cypress.yml")
    begin
      for_each_logged_in_user([ADMIN]) do
        patch :update, banner_message: 'banner test', mailer_address: 'smtp.example.com', mailer_port: 3000, mailer_domain: 'example.com',
                       mailer_user_name: 'testuser', mailer_password: 'password123'
      end
      assert_equal 'banner test', Settings['banner_message']
      assert_equal 'smtp.example.com', Rails.application.config.action_mailer.smtp_settings.address
      assert_equal 3000, Rails.application.config.action_mailer.smtp_settings.port
      assert_equal 'example.com', Rails.application.config.action_mailer.smtp_settings.domain
      assert_equal 'testuser', Rails.application.config.action_mailer.smtp_settings.user_name
      assert_equal 'password123', Rails.application.config.action_mailer.smtp_settings.password
    ensure
      File.open("#{Rails.root}/config/cypress.yml", 'w') { |file| file.puts orig_yml }
    end
  end
end
