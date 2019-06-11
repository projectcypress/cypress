module Validators
  module Validator
    def errors
      @errors ||= []
    end

    def add_error(msg, options = {})
      add_issue(msg, :error, options)
    end

    def add_warning(msg, options = {})
      add_issue(msg, :warning, options)
    end

    def add_issue(msg, msg_type, options = {})
      attributes = { message: msg, msg_type: msg_type, validator: self.class.to_s, validator_type: self.class.validator_type }.merge(options)
      @errors ||= []
      @errors << ::ExecutionError.new(attributes)
    end

    def add_errors(errors)
      self.errors.concat errors
    end

    def self.included(receiver)
      receiver.send :mattr_accessor, :validator, :validator_type
    end

    # validaton_errors from cqm-validators
    def add_cqm_validation_error_as_execution_error(validaton_errors, validation_class, validation_type, as_warning = false)
      # The HDS validators hand back ValidationError objects, but we need ExecutionError objects
      validaton_errors.map do |error|
        type = as_warning ? :warning : :error
        add_issue error.message, type, location: error.location, validator: validation_class,
                                       validator_type: validation_type, file_name: error.file_name
      end
    end

    def can_continue
      true
    end
  end
end
