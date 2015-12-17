source 'https://rubygems.org'

gem 'bson'
gem 'rails', '~> 4.1.11'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'rake'


# gem 'quality-measure-engine', :git => 'https://github.com/pophealth/quality-measure-engine.git', :branch => 'master'

# gem 'quality-measure-engine', :path => '../quality-measure-engine'

gem 'quality-measure-engine', '3.1.2'
# gem 'health-data-standards', "3.5.3"

#gem 'health-data-standards', path: "../health-data-standards"
gem 'health-data-standards',:git => 'https://github.com/projectcypress/health-data-standards.git', :branch => 'master'

#gem 'quality-measure-engine', '~> 2.5.0'
# gem 'health-data-standards',:git => 'https://github.com/ssayer/health-data-standards.git', :branch => 'validators'

# gem 'health-data-standards', :path => '../health-data-standards'

# gem 'health-data-standards', '~> 3.5.2'



#gem 'test-patient-generator', :git => 'https://github.com/pophealth/test-patient-generator.git', :branch => 'develop'
#gem 'test-patient-generator', '~> 1.2.0'

#gem "delayed_job_mongoid_web", :git => 'https://github.com/rdingwell/delayed_job_mongoid_web.git', :branch => 'develop'
gem 'delayed_job_mongoid'
gem "mongoid_rails_migrations" , "~>1.0"

gem 'highline'
# gem 'state_machine'
# Switched to AASM, because state_machine hasn't been updated in almost a year
gem 'aasm'

gem 'devise', '~> 3.2'
gem 'simple_form'

gem "prawn", :require => "prawn"
gem "prawn-table"
gem "pdf-reader", '0.9.0'

gem 'thin', :platforms => [:ruby]
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'cancan', '~> 1.6.7'


gem 'mongoid-grid_fs', '~> 2.1.0' #:git=>'https://github.com/ahoward/mongoid-grid_fs.git'

gem 'cache_digests'

gem "sass", :require => 'sass'

group :assets do
  # gem 'bootstrap-sass'
  # gem 'sass-rails'
  # gem 'coffee-rails'
  # gem 'jquery-rails' # necessary for jquery_ujs w/data-method="delete" etc
  gem 'uglifier'
end

group :test, :develop do
	gem 'pry'
  gem 'pry-nav'
  gem 'turn', :require => false
  gem "cane"
  gem 'ruby-graphviz'
  gem 'rubocop'
  gem 'overcommit'
end

group :test do
  gem 'mocha', :require => false
  gem 'webmock'
  gem 'rails-perftest'
  gem 'ruby-prof'
  gem 'simplecov'
end

group :production do
  gem 'therubyracer', :platforms => [:ruby]
  gem 'therubyrhino', :platforms => [:jruby]
end
