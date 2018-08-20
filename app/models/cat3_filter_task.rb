class Cat3FilterTask < Task
  def validators
    @validators = [::Validators::QrdaCat3Validator.new(product_test.expected_results,
                                                       false,
                                                       product_test.c3_test,
                                                       product_test.c2_test,
                                                       product_test.bundle),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]
  end

  def execute(file, user)
    te = test_executions.create(expected_results: product_test.expected_results)
    te.user = user
    te.artifact = Artifact.new(file: file)
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end

  def good_results
    cms_compatibility = product_test&.product&.c3_test
    options = { provider: product_test.patients.first.provider, submission_program: cms_compatibility, start_time: start_date, end_time: end_date }
    Qrda3R21.new(product_test.expected_results, product_test.measures, options).render
  end
end
