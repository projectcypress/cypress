# frozen_string_literal: true

class MultiMeasureCat3Task < Task
  def validators
    @validators = [::Validators::MeasurePeriodValidator.new,
                   ::Validators::QrdaCat3Validator.new(product_test.expected_results, true, true, false, product_test.bundle),
                   ::Validators::CMSQRDA3SchematronValidator.new(product_test.bundle.version, as_warnings: false),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results, product_test.bundle.randomization)]
    @validators
  end

  def execute(file, user)
    te = test_executions.new(expected_results:, artifact: Artifact.new(file:), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: true)
    te.save
    te
  end

  def good_results
    # Set the Submission Program to MIPS_INDIV
    options = { provider: product_test.patients.first.providers.first, submission_program: 'MIPS_INDIV',
                start_time: start_date, end_time: end_date, ry2025_submission: product_test.bundle.major_version == '2024',
                ry2026_submission: product_test.bundle.major_version == '2025' }
    Qrda3.new(product_test.expected_results_with_all_supplemental_codes, product_test.measures, options).render
  end
end
