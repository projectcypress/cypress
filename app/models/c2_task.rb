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
    @validators = [::Validators::QrdaCat3Validator.new(product_test.expected_results),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]

    @validators << ::Validators::MeasurePeriodValidator.new if product_test.contains_c3_task?

    @validators
  end

  def execute(file)
    te = test_executions.create(expected_results: expected_results)
    te.artifact = Artifact.new(file: file)
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.contains_c3_task?)
    te.save
    te
  end
end
