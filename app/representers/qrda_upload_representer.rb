# frozen_string_literal: true

module QrdaUploadRepresenter
  include Api::Representer
  property :validator
  property :path
  property :execution_errors

  self.embedded = {
    execution_errors: %i[file_name message validator]
  }
end
