# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.8'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.2.0'

gem 'delayed_job_mongoid', '~> 3.0.0'
gem 'mongoid', '~> 8.1.0'

# gem 'mongoid', '~> 4.0.2'
gem 'bson'

gem 'mustache'
## gem 'os'

gem 'cqm-models', '~> 4.2.0'
gem 'cqm-parsers', '~> 4.1.1.1'
gem 'cqm-reports', '~> 4.1.4'
gem 'cqm-validators', '~> 4.0.6'

# # Use faker to generate addresses
gem 'faker', '> 1.5.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.4'
# Dependencies for CMS Assets Framework
# gem 'bootstrap-sass', '~> 3.4.1'
gem 'bootstrap', '~> 5.3.3'
gem 'dartsass-sprockets'

gem 'font-awesome-sass', '~> 5.0.13'
gem 'jquery-rails'
# TODO: remove or use gem
gem 'jquery-ui-rails', '~> 8.0.0'

# Add pagination support
gem 'kaminari-mongoid'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Bake the best breadcrumbs
gem 'breadcrumbs_on_rails'
# Help our forms
gem 'bootstrap_form', '~> 2.7'
gem 'jasny-bootstrap-rails'
gem 'nested_form'

gem 'jquery-datatables-rails'
gem 'local_time', '~> 2.0.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', git: 'https://github.com/turbolinks/turbolinks-classic', branch: 'master'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.11.0'
# A set of responders modules to dry up your Rails 4.2+ app.
gem 'responders'
# Roar is a framework for parsing and rendering REST documents
gem 'multi_json'
gem 'representable', '~> 3.0.0'
gem 'roar-rails'

gem 'carrierwave', '~> 2.2.5'
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'

# AJAX file uploads
gem 'remotipart', '~> 1.2'

# Server usage statistics
gem 'vmstat'

gem 'bootsnap', require: false

# bubble up errors from embedded documents in Mongoid.
# gem 'mongoid-embedded-errors'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Devise is the gem we use for user authentication
gem 'cancancan'
gem 'devise'
gem 'devise_invitable'
gem 'rolify'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'rest-client', '~>2.0.2'
## gem 'typhoeus'

## gem 'daemons'

gem 'validate_url'

gem 'telephone_number'

group :development, :test do
  # rubocop 0.67 currently has a bug that is causing it to crash in product.rb and vendor.rb
  gem 'rubocop'
  gem 'rubocop-rspec'
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'axe-core-capybara'
  gem 'axe-core-cucumber'
  gem 'byebug'
  gem 'capybara'
  gem 'capybara-accessible'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner-mongoid'
  gem 'overcommit'
  # gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'poltergeist'
  gem 'pry'
  gem 'pry-nav'
  gem 'rails_best_practices'
  gem 'rails-controller-testing'
  gem 'rails-perftest'
  gem 'scss_lint', require: false
  gem 'selenium-webdriver'
end

group :development do
  gem 'listen'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 4.2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
end

group :test do
  # Brakeman is broken on ruby 2.5, re-enable when https://github.com/presidentbeef/brakeman/issues/1173 is closed
  # gem 'brakeman', :require => false
  gem 'bundler-audit'
  gem 'codecov', require: false
  gem 'factory_bot_rails'
  gem 'launchy'
  gem 'minitest'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'mocha', require: false
  gem 'simplecov', require: false
  gem 'simplecov-cobertura'
  gem 'vcr'
  gem 'webmock'
end

group :production do
  gem 'newrelic_rpm'
  gem 'unicorn-rails'
end

group :docker do
  gem 'puma', '~> 6.6'
end
