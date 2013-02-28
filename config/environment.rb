# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Cypress::Application.initialize!

#Force the indexes to exist
::Rails.application.eager_load!

Mongoid.models.each do |model|
  next if model.index_options.empty?
  unless model.embedded?
    model.create_indexes
  end
end
