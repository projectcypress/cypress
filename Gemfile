source 'http://rubygems.org'

#gem 'bson', '1.3.2'
gem 'rails', '3.2.2'
gem 'jquery-rails'
gem 'rake'
#gem 'quality-measure-engine', :git => 'https://github.com/pophealth/quality-measure-engine.git', :branch => 'develop' 
gem 'quality-measure-engine', '1.1.2'
#gem 'health-data-standards', :git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'develop'
gem 'health-data-standards', '0.8.0'

gem 'bson_ext', :platforms => :mri
gem 'mongoid', '~> 2.0'

gem 'devise', '~> 2.0'
gem 'simple_form'
gem 'nokogiri', '~> 1.4.4'

gem 'prawn'
gem "prawnto_2", :require => "prawnto"

gem 'pry'
gem 'pry-nav'

# Windows doesn't have syslog, so need a gem to log to EventLog instead
gem 'win32-eventlog', :platforms => [:mswin, :mingw]

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test, :develop do
  gem 'turn', :require => false
  gem 'minitest'
  gem "tailor"
  gem 'simplecov', :require => false
  gem 'mocha', :require => false
end

group :production do
  gem 'therubyracer', :platforms => [:ruby, :jruby]
end

