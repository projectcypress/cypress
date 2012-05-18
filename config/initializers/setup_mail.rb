# Allow the application to send e-mails
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.raise_delivery_errors = true
ActionMailer::Base.smtp_settings = {
  :address  => APP_CONFIG["mailer"]["address"],
  :port  => APP_CONFIG["mailer"]["port"],
  :domain => APP_CONFIG["mailer"]["domain"],
  :openssl_verify_mode => APP_CONFIG["mailer"]["openssl_verify_mode"]
}

# If you do want mail delivery in non-production environments, comment out the line below
ActionMailer::Base.register_interceptor(MailInterceptor) if Rails.env.development? || Rails.env.test?