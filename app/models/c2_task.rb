require 'validators/qrda_cat3_validator'

class C2Task < Task
  # C2 = Import and Calculate
  #  - Ability to Import Cat 1
  #  - Calculate every CQM
  #  - (implied) ability to export cat 3 (in order to be able to prove it)
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = [::Validators::QrdaCat3Validator.new(product_test.expected_results, product_test.product.c3_test, product_test.bundle),
                   ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]

    @validators
  end

  def execute(file)
    te = test_executions.create(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.sibling_execution_id = product_test.tasks.c3_cat3_task.execute(file, te.id).id if product_test.product.c3_test
    te.save
    te
  end

  def good_results
    cat1_zip = Cypress::CreateDownloadZip.create_zip(records, 'qrda')
    c3c = Cypress::Cat3Calculator.new(product_test.measure_ids, product_test.bundle)
    c3c.import_cat1_zip(cat1_zip)
    c3c.generate_cat3
  end

  # returns combined status including c3_cat3 task
  def status_with_sibling
    sibling = product_test.tasks.c3_cat3_task
    return status unless sibling
    return status if status == sibling.status
    return 'errored' if errored? || sibling.errored?
    return 'incomplete' if incomplete? || sibling.incomplete?
    'failing'
  end
end
