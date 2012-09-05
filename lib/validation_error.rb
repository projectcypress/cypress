module Cypress

  # Classes used to record errors and warnings produced by Validators.
  class ValidationError
  
    include Mongoid::Document
    field :section, type: String
    field :subsection,  type: String
    field :field_name, type: String
    field :message, type: String
    field :location, type: String
    field :severity, type: String
    field :validator, type: String
    field :inspection_type, type: String
    field :exception, type: String
    
  end
end
