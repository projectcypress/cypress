class MultiMeasureCat3Task < Task
  def validators
    @validators = [::Validators::MeasurePeriodValidator.new,
                   ::Validators::QrdaCat3Validator.new(product_test.expected_results, true, true, false, product_test.bundle),
                   ::Validators::CMSQRDA3SchematronValidator.new(product_test.bundle.version, false),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]
    @validators
  end

  def execute(file, user)
    te = test_executions.new(expected_results: expected_results, artifact: Artifact.new(file: file), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: true)
    te.save
    te
  end

  def good_results
    cms_compatibility = product_test&.product&.c3_test
    options = { provider: product_test.patients.first.providers.first, submission_program: cms_compatibility,
                start_time: start_date, end_time: end_date }
    Qrda3R21.new(product_test.expected_results, product_test.measures, options).render
  end
end
