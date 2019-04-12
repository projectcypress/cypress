class MultiMeasureCat1Task < Task
  def validators
    @validators = [::Validators::CalculatingSmokingGunValidator.new(product_test.measures, product_test.patients, product_test.id),
                   ::Validators::MeasurePeriodValidator.new,
                   ::Validators::CMSQRDA1HQRSchematronValidator.new(product_test.bundle.version, false),
                   ::Validators::QrdaCat1Validator.new(product_test.bundle, true, true, false, product_test.measures)]
    @validators
  end

  def execute(file, user)
    te = test_executions.new(expected_results: expected_results, artifact: Artifact.new(file: file), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: true)
    te.save
    te
  end

  def patients
    patient_ids = product_test.results.where('IPP' => { '$gt' => 0 }).collect(&:patient)
    product_test.patients.in('_id' => patient_ids)
  end

  def good_results
    Cypress::CreateDownloadZip.create_zip(patients, 'qrda').read
  end
end
