class MailInterceptor
  def self.delivering_email(message)
    message.perform_deliveries = false
  end
end
