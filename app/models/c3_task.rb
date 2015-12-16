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

  def execute(file)
    te = test_executions.create(expected_results: expected_results)
    te.qrda_type = last_execution
    te.artifact = Artifact.new(file: file)
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.contains_c3_task?)
    te.save
    te
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      report_status = 'incomplete'
      statuses = []
      statuses << test_execution_status('Cat1') if has_cat_1
      statuses << test_execution_status('Cat3') if has_cat_3
      if statuses.include? 'failing'
        report_status = 'failing'
      elsif statuses.include? 'incomplete'
        report_status = 'incomplete'
      elsif statuses.size > 0
        report_status = 'passing'
      end
      report_status
    end
  end

  def test_execution_status(qrda_type)
    if test_executions.where(qrda_type: qrda_type).order_by(created_at: 'desc').size > 0
      recent_execution = test_executions.where(qrda_type: qrda_type).order_by(created_at: 'desc').first
      if recent_execution.passing?
        report_status = 'passing'
      elsif recent_execution.failing?
        report_status = 'failing'
      end
    else
      report_status = 'incomplete'
    end
    report_status
  end
end
