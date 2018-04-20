source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.7'

# Use MongoDB just like in Cypress v2!
gem 'mongoid', '~> 5.0.0'
# gem 'mongoid', '~> 4.0.2'
gem 'bson_ext'

gem 'os'

gem 'cql_qdm_patientapi', :git => 'https://github.com/projecttacoma/cql_qdm_patientapi', :branch => 'better_codes_and_scalar_error'
gem 'cqm-converter', :git => 'https://github.com/projecttacoma/cqm-converter.git', :branch => 'camelCase_updated'
gem 'cqm-models', :git => 'https://github.com/projecttacoma/cqm-models', :branch => 'master'

gem 'health-data-standards', git: 'https://github.com/projectcypress/health-data-standards.git', branch: 'r5'
# gem 'health-data-standards', '~> 3.7.0'

gem 'quality-measure-engine',
    git: 'https://github.com/projectcypress/quality-measure-engine.git', branch: 'bump_mongoid'

# Use faker to generate addresses
gem 'faker', '~> 1.5.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.4'
# Dependencies for CMS Assets Framework
gem 'bootstrap-sass', '~> 3.3.5'
gem 'font-awesome-sass'
gem 'jquery-rails', '~> 4.0.4'
gem 'jquery-ui-rails', '~> 5.0.5'
gem 'modernizr-rails', '~> 2.7.1'

# Add pagination support
gem 'kaminari-mongoid'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Bake the best breadcrumbs
gem 'breadcrumbs_on_rails'
# Help our forms
gem 'bootstrap_form'
gem 'jasny-bootstrap-rails'
gem 'nested_form'

gem 'jquery-datatables-rails', '~> 3.3.0'

gem 'local_time', '~> 2.0.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', git: 'https://github.com/turbolinks/turbolinks-classic', branch: 'master'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# A set of responders modules to dry up your Rails 4.2+ app.
gem 'responders'
# Roar is a framework for parsing and rendering REST documents
gem 'roar-rails'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', :group => :doc

gem 'carrierwave', '~> 0.11.2'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'

# AJAX file uploads
gem 'remotipart', '~> 1.2'

# Server usage statistics
gem 'vmstat'

# bubble up errors from embedded documents in Mongoid.
# gem 'mongoid-embedded-errors'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Devise is the gem we use for user authentication
gem 'cancancan'
gem 'devise', '4.1.1'
gem 'devise_invitable'
gem 'rolify'

gem 'mongoid_rails_migrations', :git => 'https://github.com/adacosta/mongoid_rails_migrations.git', :branch => 'master'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem 'rubocop', '0.49', :require => false
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'axe-matchers'
  gem 'byebug'
  gem 'capybara'
  gem 'capybara-accessible'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'overcommit'
  gem 'poltergeist'
  gem 'pry'
  gem 'pry-nav'
  gem 'rails-perftest'
  gem 'rails_best_practices'
  gem 'ruby-prof', '~> 0.15.9'
  gem 'scss_lint', :require => false
  gem 'selenium-webdriver'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
end

group :test do
  gem 'brakeman', :require => false
  gem 'bundler-audit'
  gem 'codecov', :require => false
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'minitest', '5.10.3'
  gem 'minitest-rails'
  gem 'minitest-reporters'
  gem 'mocha', :require => false
  gem 'simplecov', :require => false
end

group :production do
  gem 'newrelic_rpm'
  gem 'unicorn-rails'
end
