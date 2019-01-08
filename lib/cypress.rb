Dir[File.dirname(__FILE__) + '/cypress/*.rb'].each { |file| require file }.each { |file| require file }
Dir[File.dirname(__FILE__) + '/cypress/patient_export/*.rb'].each { |file| require file }.each { |file| require file }
Dir[File.dirname(__FILE__) + '/ext/*.rb'].each { |file| require file }.each { |file| require file }
Dir[File.dirname(__FILE__) + '/validators/*.rb'].each { |file| require file }.each { |file| require file }
require_relative 'bootstrap_breadcrumbs_builder.rb'
require_relative 'job_status.rb'
