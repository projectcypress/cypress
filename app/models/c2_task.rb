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
    return @validators if @validators

    @has_cat3 = product_test.contains_c3_task?

    @validators = [::Validators::QrdaCat3Validator.new(product_test.expected_results),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]

    @validators << ::Validators::MeasurePeriodValidator.new if @has_cat3

    @validators
  end

  def execute(file)
    te = test_executions.create(expected_results: expected_results)
    te.artifact = Artifact.new(file: file)
    te.validate_artifact(validators, te.artifact, validate_reporting: @has_cat3)
    te.save
    te
  end
end
