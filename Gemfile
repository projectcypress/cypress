source 'http://rubygems.org'

#gem 'bson', '1.3.2'
gem 'rails', '3.2.11'
gem 'jquery-rails'
gem 'rake'


#gem 'quality-measure-engine', :git => 'https://github.com/pophealth/quality-measure-engine.git', :branch => 'develop'


gem 'quality-measure-engine', '~> 2.3.0'
# gem 'health-data-standards',:git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'develop'

gem 'health-data-standards', '~> 3.0.6'


#gem 'test-patient-generator', :git => 'https://github.com/pophealth/test-patient-generator.git', :branch => 'develop'
gem 'test-patient-generator', '~> 1.2.0'

gem "delayed_job_mongoid_web", :git => 'https://github.com/rdingwell/delayed_job_mongoid_web.git', :branch => 'develop'

gem "mongoid_rails_migrations" , "~>1.0"


gem 'state_machine'

gem 'devise', '~> 2.0'
gem 'simple_form'

gem "prawn"
gem "pdf-reader", '0.9.0'

gem 'thin', :platforms => [:ruby]


gem 'cancan', '~> 1.6.7'


gem 'mongoid-grid_fs', '~> 1.7.0' #:git=>'https://github.com/ahoward/mongoid-grid_fs.git'



group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test, :develop do
	gem 'pry'
  gem 'pry-nav'
  gem 'turn', :require => false
  gem 'minitest'
  gem "tailor"
  gem 'simplecov', :require => false
  gem 'mocha', :require => false
  gem 'webmock'
end

group :production do
  gem 'therubyracer', :platforms => [:ruby]
  gem 'therubyrhino', :platforms => [:jruby]
end


