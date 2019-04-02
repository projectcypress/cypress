class MultiMeasureCat1Task < Task
  def validators
    # not using the "calculating" smoking gun validator here
    # because we only want the record (patient) inclusion test from the regular version
    @validators = [::Validators::CalculatingSmokingGunValidator.new(product_test.measures, product_test.patients, product_test.id),
                   ::Validators::MeasurePeriodValidator.new,
                   ::Validators::CMSQRDA1HQRSchematronValidator.new(product_test.bundle.version, false),
                   ::Validators::QrdaCat1Validator.new(product_test.bundle, true, true, false, product_test.measures)]
    @validators
  end

  def execute(file, user)
    te = test_executions.create(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.user = user
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: true)
    te.save
    te
  end

  def good_results
    Cypress::CreateDownloadZip.create_zip(patients, 'qrda').read
  end
end
