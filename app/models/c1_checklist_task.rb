# frozen_string_literal: true

require 'validators/checklist_criteria_validator'

class C1ChecklistTask < Task
  include Mongoid::Attributes::Dynamic
  include ::Validators

  # C1 = Record and Export
  #  - Record all the data needed to calculate CQMs
  #  - Export data as Cat 1
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = [ChecklistCriteriaValidator.new(product_test),
                   ::Validators::QrdaCat1Validator.new(product_test.bundle, false, product_test.c3_test, true, product_test.measures)]
    @validators
  end

  def execute(file, user)
    te = test_executions.new(artifact: Artifact.new(file:), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.sibling_execution_id = product_test.tasks.c3_checklist_task.execute(file, user, te.id).id if product_test.c3_cat1_task?
    te.save
    te
  end
end
