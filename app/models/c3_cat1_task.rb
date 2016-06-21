class C3Cat1Task < Task
  def validators
    # not using the "calculating" smoking gun validator here
    # because we only want the record inclusion test from the regular version
    @validators = [::Validators::SmokingGunValidator.new(product_test.measures, product_test.records, product_test.id,
                                                         suppress_errors: true, validate_inclusion_only: true),
                   ::Validators::MeasurePeriodValidator.new,
                   ::Validators::QrdaCat1Validator.new(product_test.bundle, true, true, product_test.measures)]
    @validators << cms_cat1_schematron_validator
    @validators
  end

  def cms_cat1_schematron_validator
    measure = product_test.measures[0]
    if measure.type == 'eh'
      ::Validators::CMSQRDA1HQRSchematronValidator.new(product_test.bundle.version)
    else
      ::Validators::CMSQRDA1PQRSSchematronValidator.new(product_test.bundle.version)
    end
  end

  def execute(file, sibling_execution_id)
    te = test_executions.create(expected_results: expected_results, artifact: Artifact.new(file: file))
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.product.c3_test)
    te.sibling_execution_id = sibling_execution_id
    te.save
    te
  end
end
