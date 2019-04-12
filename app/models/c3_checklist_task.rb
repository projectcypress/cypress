class C3ChecklistTask < Task
  # include Mongoid::Attributes::Dynamic
  include ::Validators

  def validators
    @validators = [::Validators::QrdaCat1Validator.new(product_test.bundle, true, true, product_test.c1_test, product_test.measures)]
    @validators
  end

  def execute(file, user, sibling_execution_id)
    te = test_executions.new(artifact: Artifact.new(file: file), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.sibling_execution_id = sibling_execution_id
    te.save
    te
  end
end
