module Admin
  class SettingsController < ApplicationController
    add_breadcrumb 'Admin', :admin_path
    before_action -> { fail CanCan::AccessDenied.new, 'Forbidden' unless current_user.has_role? :admin }

    def show
      redirect_to admin_path(anchor: 'application_settings')
    end

    def edit
      add_breadcrumb 'Edit', :edit_settings_path
      smtp_settings = Rails.application.config.action_mailer.smtp_settings
      render locals: {
        banner_message: Settings.banner_message,
        address: smtp_settings.address,
        port: smtp_settings.port,
        domain: smtp_settings.domain,
        user_name: smtp_settings.user_name,
        password: smtp_settings.password
      }
    end

    def update
      Settings[:banner_message] = params[:banner_message]
      smtp_hash = {}
      smtp_hash[:address] = params[:address] unless params[:address].empty?
      smtp_hash[:port] = params[:port] unless params[:port].empty? || !valid_port?(params[:port])
      smtp_hash[:domain] = params[:domain]
      smtp_hash[:user_name] = params[:user_name]
      smtp_hash[:password] = params[:password]
      Rails.application.config.action_mailer.smtp_settings.merge!(smtp_hash)
      redirect_to admin_path(anchor: 'bundle')
    end

    def valid_port?(port_str)
      true if (1..65_535).cover?(port_str.to_i)
    end
  end
end
