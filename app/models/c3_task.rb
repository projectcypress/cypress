class C3Task < Task
  def validators
    @validators ||= [::Validators::QrdaCat3Validator.new(product_test.expected_results),
                     ::Validators::MeasurePeriodValidator.new,
                     ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]
  end

  def execute(file)
    te = test_executions.create(expected_results: expected_results)
    te.artifact = Artifact.new(file: file)
    te.validate_artifact(validators, te.artifact, reported_results_target: self)
    te.save
    te
  end
end
