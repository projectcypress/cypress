require 'validators/checklist_criteria_validator'

class C1ManualTask < Task
  include Mongoid::Attributes::Dynamic
  include ::Validators

  # C1 = Record and Export
  #  - Record all the data needed to calculate CQMs
  #  - Export data as Cat 1
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = [ChecklistCriteriaValidator.new(product_test)]
    @validators
  end

  def execute(file)
    te = test_executions.new(artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end
end
