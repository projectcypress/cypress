# frozen_string_literal: true

class QrdaUploadTask < Task
  include Mongoid::Attributes::Dynamic
  include ActionView::Helpers::NumberHelper
  include ::CqmValidators

  field :year, type: String
  field :qrda_type, type: String
  field :organization, type: String

  def validators
    @validators = [::Validators::QrdaUploadValidator.new(year, qrda_type, organization)]
    @validators
  end

  def execute(file, user)
    te = test_executions.new(artifact: Artifact.new(file: file), user_id: user)
    te.validate_artifact(validators, te.artifact) if check_file_size(te)
    te
  end

  def check_file_size(test_execution)
    file_count = 0
    artifact = test_execution.artifact
    artifact.each do
      # count files first
      file_count += 1
    end

    if file_count > APP_CONSTANTS['zip_file_count_limit'] || artifact.file.size > APP_CONSTANTS['zip_file_size_limit']
      # limits exceeded
      msg = "File has size of #{number_to_human_size(artifact.file.size)} and file count of #{file_count} which " \
            "exceeds upload limits of #{number_to_human_size(APP_CONSTANTS['zip_file_size_limit'])} " \
            "and #{APP_CONSTANTS['zip_file_count_limit']} files."
      test_execution.execution_errors.build(message: msg, msg_type: :error)
      return false
    end
    true
  end
end
