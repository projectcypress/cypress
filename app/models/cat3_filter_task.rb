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
    te = test_executions.new(expected_results: product_test.expected_results, artifact: Artifact.new(file: file), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end

  def good_results
    # Set the Submission Program to MIPS_INDIV if there is a C3 test and the test is for an ep measure.
    cat3_submission_program = if product_test&.product&.c3_test
                                product_test&.measures&.first&.reporting_program_type == 'ep' ? 'MIPS_INDIV' : false
                              else
                                false
                              end
    options = { provider: product_test.patients.first.providers.first, submission_program: cat3_submission_program,
                start_time: start_date, end_time: end_date }
    Qrda3R21.new(product_test.expected_results, product_test.measures, options).render
  end
end
