class Cat1FilterTask < Task
  include ::Validators
  # C1 = Record and Export
  #  - Record all the data needed to calculate CQMs
  #  - Export data as Cat 1
  #
  # Also, if the parent product test includes a C3 Task,
  # do that validation here
  def validators
    @validators = [QrdaCat1Validator.new(product_test.bundle, false, product_test.measures),
                   ::Validators::SmokingGunValidator.new(product_test.measures, records, product_test.id)]

    @validators
  end

  def execute(file)
    te = test_executions.new(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end

  def records
    patient_ids = product_test.results.where('value.IPP' => { '$gt' => 0 }).collect { |pc| pc.value.patient_id }
    product_test.filtered_records.in('_id' => patient_ids)
  end
end
