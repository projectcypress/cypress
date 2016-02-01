class C3Task < Task
  # C3 = Report
  #  - Ability to create a data file
  #  - Cat 1 R3 or Cat 3
  # This validation will be rolled into the C1 and C2 tasks
  # and the C3 task won't have its own dedicated upload.
  field :has_cat_1, type: Boolean
  field :has_cat_3, type: Boolean
  field :last_execution, type: String

  def validators
    if last_execution == 'Cat1'
      if product_test.contains_c3_task?
        c3_validation = true
        @validators = [::Validators::MeasurePeriodValidator.new,
                       ::Validators::QrdaCat1Validator.new(product_test.bundle, c3_validation, product_test.measures)]
      end
    elsif last_execution == 'Cat3'
      if product_test.contains_c3_task?
        @validators = [::Validators::MeasurePeriodValidator.new,
                       ::Validators::QrdaCat3Validator.new(product_test.expected_results)]
      end
    end
    @validators
  end

  def cat3
    self.last_execution = 'Cat3'
  end

  def cat1
    self.last_execution = 'Cat1'
  end

  def execute(file, sibling_execution_id)
    te = test_executions.create(expected_results: expected_results)
    te.qrda_type = last_execution
    te.artifact = Artifact.new(file: file)
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.contains_c3_task?)
    te.sibling_execution_id = sibling_execution_id
    te.save
    te
  end
end
