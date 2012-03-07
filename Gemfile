source 'http://rubygems.org'

gem 'rails', '3.2'
gem 'jquery-rails'
gem 'rake'
gem 'quality-measure-engine', :git => 'https://github.com/pophealth/quality-measure-engine.git', :branch => 'master'
gem 'bson_ext', :platforms => :mri
gem 'mongoid', '~> 2.0'
gem 'devise', '~> 2.0'
gem 'simple_form'
gem 'nokogiri', '~> 1.4.4' 
gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'master'
#gem 'health-data-standards', :path => '../../shared/HealthDataStandards'
gem 'prawn'
gem "prawnto_2", :require => "prawnto"
gem 'pry'
gem 'pry-nav'

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test, :develop do
  gem 'turn', :require => false
  gem 'minitest'
  gem 'cover_me', '>= 1.0.0.rc6'
end

group :production do
  gem 'therubyracer', :platforms => [:ruby, :jruby]
end

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'


# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19', :require => 'ruby-debug'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
# group :development, :test do
#   gem 'webrat'
# end
