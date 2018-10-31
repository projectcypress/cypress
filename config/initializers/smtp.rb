# This will apply the current mailer settings on app startup.
unless ENV['DISABLE_SMTP_SETTINGS']
  Settings.current&.apply_mailer_settings
end
