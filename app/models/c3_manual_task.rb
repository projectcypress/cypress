class C3ManualTask < Task
  # include Mongoid::Attributes::Dynamic
  include ::Validators

  def validators
    @validators = [::Validators::QrdaCat1Validator.new(product_test.bundle, true, true, product_test.measures),
                   ::Validators::MeasurePeriodValidator.new]
    @validators
  end

  def execute(file, sibling_execution_id)
    te = test_executions.new(artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.sibling_execution_id = sibling_execution_id
    te.save
    te
  end
end
