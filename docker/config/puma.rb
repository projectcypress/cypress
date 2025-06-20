port ENV.fetch('PORT', 3000)
environment ENV.fetch('RAILS_ENV', 'development')
workers ENV.fetch('WEB_CONCURRENCY', 2)
preload_app!
