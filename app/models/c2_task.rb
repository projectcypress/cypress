require 'validators/qrda_cat3_validator'

class C2Task < Task
  # C2 = Import and Calculate
  #  - Ability to Import Cat 1
  #  - Calculate every CQM
  #  - (implied) ability to export cat 3 (in order to be able to prove it)
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = [::Validators::QrdaCat3Validator.new(product_test.expected_results, product_test.product.c3_test),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]

    @validators
  end

  def execute(file)
    te = test_executions.create(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.product.c3_test)
    te.sibling_execution_id = product_test.tasks.c3_cat3_task.execute(file, te.id).id if product_test.product.c3_test
    te.save
    te
  end
end
