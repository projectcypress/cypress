# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cypress::Application.initialize!

# We're extending the Record model from HealthDataStandards, so we need to require our version
# to force the redefinition.
require_relative '../app/models/record.rb'