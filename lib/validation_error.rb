module Cypress

  # Classes used to record errors and warnings produced by Validators.
  class ValidationError < ExecutionError
    field :message, type: String
    field :location, type: String
    field :validator, type: String 
  end
end
