source 'http://rubygems.org'

#gem 'bson', '1.3.2'
gem 'rails', '3.2.2'
gem 'jquery-rails'
gem 'rake'
gem 'quality-measure-engine', '~> 2.1.0'
gem 'health-data-standards', '~> 2.1.4'
gem 'hqmf-parser', ' ~> 1.0.6'

#gem 'hqmf-parser', path: '../hqmf-parser'
#gem 'test-patient-generator', :git => 'https://github.com/pophealth/test-patient-generator.git', :branch => 'develop'
gem 'test-patient-generator', '~> 1.0.2'
#gem 'test-patient-generator', :path => '../pophealth/test-patient-generator'


gem "delayed_job_mongoid_web", :git => 'https://github.com/rdingwell/delayed_job_mongoid_web.git', :branch => 'develop'
gem 'state_machine'

gem 'devise', '~> 2.0'
gem 'simple_form'

gem "prawn"
gem  "pdf-reader", '0.9.0'

gem 'thin'




gem 'mongoid-grid_fs', '~> 1.3.3' #:git=>'https://github.com/ahoward/mongoid-grid_fs.git'

# Windows doesn't have syslog, so need a gem to log to EventLog instead
gem 'win32-eventlog', :platforms => [:mswin, :mingw]

group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :test, :develop do
	gem 'pry'
  #gem 'pry-debugger'
  gem 'turn', :require => false
  gem 'minitest'
  gem "tailor"
  gem 'simplecov', :require => false
  gem 'mocha', :require => false
end

group :production do
  gem 'therubyracer', :platforms => [:ruby, :jruby]
end

