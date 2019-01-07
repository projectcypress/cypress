class C1Task < Task
  include Mongoid::Attributes::Dynamic

  # C1 = Record and Export
  #  - Record all the data needed to calculate CQMs
  #  - Export data as Cat 1
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = if product_test.c1_test
                    [::Validators::CalculatingSmokingGunValidator.new(product_test.measures, product_test.patients, product_test.id),
                     ::Validators::QrdaCat1Validator.new(product_test.bundle, false, product_test.c3_test, true, product_test.measures)]
                  else
                    # A C1 task is created whenever C3 is selected.  If C1 isn't also selected, this task doesn't perform any validations
                    []
                  end
    @validators
  end

  def execute(file, user)
    te = test_executions.new(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.user = user
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.sibling_execution_id = product_test.tasks.c3_cat1_task.execute(file, user, te.id).id if product_test.c3_test
    te.save
    te
  end

  def patients
    # TODO: R2P: Collect using patient cache (calculation results)
    patient_ids = product_test.results.where('IPP' => { '$gt' => 0 }).collect(&:patient)
    product_test.patients.in('_id' => patient_ids)
  end

  def good_results
    Cypress::CreateDownloadZip.create_zip(patients, 'qrda').read
  end

  def last_updated_with_sibling
    sibling = product_test.tasks.c3_cat1_task
    return updated_at unless sibling

    [updated_at, sibling.updated_at].max
  end

  # returns combined status including c3_cat1 task
  def status_with_sibling
    sibling = product_test.tasks.c3_cat1_task
    return status unless sibling
    return status if status == sibling.status
    return 'errored' if errored? || sibling.errored?
    return 'incomplete' if incomplete? || sibling.incomplete?

    'failing'
  end
end
