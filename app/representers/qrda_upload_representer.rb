module QrdaUploadRepresenter
  include API::Representer
  property :validator
  property :path
  property :execution_errors

  self.embedded = {
    execution_errors: %i[file_name message validator]
  }
end
