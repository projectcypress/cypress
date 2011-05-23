# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'resque/tasks'

# The following two modules are required to work around a bug
# introduced in Rake 0.9.0
module ::Cypress
  class Application
    include Rake::DSL
  end
end

module ::RakeFileUtils
  extend Rake::FileUtilsExt
end
# end work around

Cypress::Application.load_tasks

task "resque:setup" => :environment
