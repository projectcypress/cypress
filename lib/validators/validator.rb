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
      attributes = { message: msg, msg_type: msg_type,
                     validator_type: self.class.validator_type }.merge(options)
      @errors ||= []
      @errors << ::ExecutionError.new(attributes)
    end

    def add_errors(errors)
      self.errors.concat errors
    end

    def self.included(receiver)
      receiver.send :mattr_accessor, :validator_type
    end
  end
end
