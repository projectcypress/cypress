class Cat3FilterTask < Task
  def validators
    @validators = [::Validators::MeasurePeriodValidator.new,
                   ::Validators::QrdaCat3Validator.new(product_test.expected_results)]
  end

  def execute(file)
    te = test_executions.create(expected_results: expected_results)
    te.qrda_type = last_execution
    te.artifact = Artifact.new(file: file)
    te.save
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end
end
