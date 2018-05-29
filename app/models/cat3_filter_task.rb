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
    c3c = Cypress::Cat3Calculator.new(product_test.measure_ids, product_test.bundle, product_test.effective_date)
    c3c.generate_cat3_for_test(product_test.id)
  end
end
