class Settings
  include Mongoid::Document

  # If you are adding a new field, you should add a default value here, however
  # note that you will also need to add a migration in order to setup the field
  # to a sane default value for existing users! Migrations are run every time
  # the app is upgraded by the upgrade script, however they are not run for
  # users of the docker containers.

  field :default_bundle, type: String, default: '3.0.0'
  field :enable_logging, type: Boolean, default: false
  # set to true to enable a banner at the top of every page with the "banner_message" text from below
  field :banner, type: Boolean, default: false
  field :banner_message, type: String, default: 'This server is for demonstration purposes; data on it will be removed every '\
                                                'Saturday at 11:59 PM Eastern Time'
  field :warning_message, type: String, default: 'This warning banner provides privacy and security notices consistent with '\
                                                 'applicable federal laws, directives, and other federal guidance for accessing '\
                                                 'this Government system, which includes all devices/storage media attached to '\
                                                 'this system. This system is provided for Government-authorized use only. '\
                                                 'Unauthorized or improper use of this system is prohibited and may result in '\
                                                 'disciplinary action and/or civil and criminal penalties. At any time, and for '\
                                                 'any lawful Government purpose, the government may monitor, record, and audit '\
                                                 'your system usage and/or intercept, search and seize any communication or data '\
                                                 'transiting or stored on this system. Therefore, you have no reasonable expectation '\
                                                 'of privacy. Any communication or data transiting or stored on this system may be '\
                                                 'disclosed or used for any lawful Government purpose.'
  # ignore roles completely -- this is essentially the same as everyone in the system being an admin, default true
  field :ignore_roles, type: Boolean, default: (ENV['IGNORE_ROLES'].nil? ? true : ENV['IGNORE_ROLES'].to_boolean)
  # enable the "debug features" such as allowing QA testers to produce known good results for a task, default true
  field :enable_debug_features, type: Boolean, default: (ENV['ENABLE_DEBUG_FEATURES'].nil? ? true : ENV['ENABLE_DEBUG_FEATURES'].to_boolean)
  # the default role to assign to a user upon at creation -- this should be either admin,atl, user or nil
  # a user without a role will not be able to create or view any vendors .  You may want to set this to nil
  # when an admin is required to approve new users and have the admin set the role there, default :user
  field :default_role, type: Symbol, default: ((!ENV['DEFAULT_ROLE'].nil? && ENV['DEFAULT_ROLE'].empty?) ? nil : (ENV['DEFAULT_ROLE'] || :user))
  field :auto_approve, type: Boolean, default: (ENV['AUTO_APPROVE'].nil? ? true : ENV['AUTO_APPROVE'].to_boolean)
  # sets whether or not Users are automatically linked to a Vendor based off the vendors points of contacts. Setting to true will
  # auto associate a User to a vendor when a user is created and a vendor point of contanct contains the same email address as the
  # user.  Likewise if a point of contact is added to a vendor and a User in the system has the same email address then the user
  # will be associated with the vendor.  The association is also automatically updated/rmoved when the user is removed from the system
  # or the point of contact is removed or updated from the vendor.  Setting this to true will also enable the devise plugin confirmable
  # which will require users to confirm their registration via an email link sent to their address.
  # Setting this to false disables the automatic associations as well as the devise confirmable pluggin
  field :auto_associate_pocs, type: Boolean, default: false
  field :auto_confirm, type: Boolean, default: true
  field :bundle_file_path, type: String, default: 'temp/bundles'
  field :file_upload_root, type: String, default: 'data/upload/'
  field :pid_dir, type: String, default: './tmp/delayed_pids'
  field :server_needs_restart, type: Boolean, default: false

  field :website_domain, type: String, default: (Rails.env == 'production' ? ENV['WEBSITE_DOMAIN'] : 'localhost')
  field :website_port, type: Integer, default: (Rails.env == 'production' ? (ENV['WEBSITE_PORT'] || 80) : 3000)
  field :mailer_address, type: String, default: (ENV['MAILER_ADDRESS'] || '')
  field :mailer_port, type: Integer, default: (ENV['MAILER_PORT'] || '')
  field :mailer_domain, type: String, default: (ENV['MAILER_DOMAIN'] || '')
  field :mailer_user_name, type: String, default: (ENV['MAILER_USER_NAME'] || '')
  field :mailer_password, type: String, default: (ENV['MAILER_PASSWORD'] || '')
  field :mailer_authentication, type: Symbol, default: 'plain'

  validate :instance_is_singleton

  after_update :sync_bundle
  after_save :clear_settings_cache
  before_destroy :clear_settings_cache

  # This model should only be called using this method
  def self.current
    Rails.cache.fetch('settings') do
      first_or_create
    end
  end

  def self.apply_mailer_settings
    settings_instance = current

    ActionMailer::Base.default_url_options = Cypress::Application.config.action_mailer.default_url_options = {
      host: settings_instance.website_domain,
      port: settings_instance.website_port
    }

    ActionMailer::Base.smtp_settings = Cypress::Application.config.action_mailer.smtp_settings = {
      address: settings_instance.mailer_address,
      port: settings_instance.mailer_port,
      domain: settings_instance.mailer_domain,
      user_name: settings_instance.mailer_user_name,
      password: settings_instance.mailer_password,
      authentication: settings_instance.mailer_authentication,
      enable_starttls_auto: true
    }

    true
  end

  private

  def sync_bundle
    if default_bundle_changed?
      # sync default bundle with settings
      Bundle.each do |bundle|
        bundle.active = bundle.version == default_bundle
        bundle.save!
      end
    end
  end

  def clear_settings_cache
    Rails.cache.delete('settings')
  end

  def instance_is_singleton
    singleton = Settings.first
    errors.add(:base, 'Only one settings instance is allowed') if self != singleton && !singleton.nil?
  end
end
