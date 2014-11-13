# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require 'rails'

require File.expand_path('../config/application', __FILE__)
require 'rake'
require "quality-measure-engine"

Cypress::Application.load_tasks
ENV['DB_NAME'] = "cypress_#{Rails.env}"
task "resque:setup" => :environment

Rake::TestTask.new(:test_unit) do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

Rake::Task["test"].clear
task :test => [:test_unit] do
  Rake::Task["quality_post"].invoke
  system("open coverage/index.html")
end

task :test_unit => :quality_pre
