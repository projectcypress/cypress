# frozen_string_literal: true

port ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')
workers ENV.fetch('WEB_CONCURRENCY', 4)
preload_app!
