# This will apply the current mailer settings on app startup.

Settings.current&.apply_mailer_settings unless ENV['DISABLE_DB']

