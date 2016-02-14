class Cat3FilterTask < Task
  def validators
    @validators = [::Validators::QrdaCat3Validator.new(product_test.expected_results),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]
  end

  def execute(file)
    te = test_executions.create(expected_results: product_test.expected_results)
    te.artifact = Artifact.new(file: file)
    te.save
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end
end
