source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7'

# Use MongoDB just like in Cypress v2!
gem 'mongoid', '~> 5.0.0'
# gem 'mongoid', '~> 4.0.2'
gem 'bson_ext'

gem 'health-data-standards', git: 'https://github.com/projectcypress/health-data-standards.git', branch: 'mongoid5'

gem 'quality-measure-engine',
    git: 'https://github.com/projectcypress/quality-measure-engine.git', branch: 'bump_mongoid'

# Use faker to generate addresses
gem 'faker', '~> 1.5.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.4'
# Dependencies for CMS Assets Framework
gem 'bootstrap-sass', '~> 3.3.5'
gem 'jquery-rails', '~> 4.0.4'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'modernizr-rails', '~> 2.7.1'
gem 'font-awesome-sass'

# Add pagination support
gem 'kaminari-mongoid'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Bake the best breadcrumbs
gem 'breadcrumbs_on_rails'
# Help our forms
gem 'bootstrap_form', git: 'https://github.com/bootstrap-ruby/rails-bootstrap-forms.git', branch: 'master'
gem 'nested_form'
gem 'jasny-bootstrap-rails'

gem 'jquery-datatables-rails', '~> 3.3.0'

gem 'local_time'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '2.5.3'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# A set of responders modules to dry up your Rails 4.2+ app.
gem 'responders'
# Roar is a framework for parsing and rendering REST documents
gem 'roar-rails'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', :group => :doc

gem 'carrierwave'
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'

# AJAX file uploads
gem 'remotipart', '~> 1.2'

# Server usage statistics
gem 'vmstat'

# bubble up errors from embedded documents in Mongoid.
# gem 'mongoid-embedded-errors'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Devise is the gem we use for user authentication
gem 'devise', '4.1.1'
gem 'cancancan'
gem 'rolify'
gem 'devise_invitable'
gem 'daemons'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'rubocop', '0.39', require: false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'overcommit'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner', git: 'https://github.com/DatabaseCleaner/database_cleaner.git'
  gem 'poltergeist'
  gem 'scss_lint', require: false
  gem 'capybara'
  gem 'capybara-accessible'
  gem 'axe-matchers'
  gem 'selenium-webdriver', '2.48.0'
  gem 'parallel_tests'
  gem 'pry'
  gem 'pry-nav'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
end

group :test do
  gem 'mocha', require: false
  gem 'fakefs', require: 'fakefs/safe'
  gem 'factory_girl_rails'
  gem 'minitest'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'simplecov', require: false
  gem 'brakeman', require: false
  gem 'bundler-audit'
  gem 'launchy'
end

group :production do
  gem 'unicorn-rails'
  gem 'newrelic_rpm'
end
