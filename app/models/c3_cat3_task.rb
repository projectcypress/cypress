class C3Cat3Task < Task
  def validators
    @validators = [::Validators::MeasurePeriodValidator.new,
                   ::Validators::QrdaCat3Validator.new(product_test.expected_results, true, true, product_test.c2_test, product_test.bundle)]
    cms_cat3_schematron_validator if product_test.bundle.cms_schematron
    @validators
  end

  def cms_cat3_schematron_validator
    measure = product_test.measures[0]
    @validators << ::Validators::CMSQRDA3SchematronValidator.new(product_test.bundle.version) if measure.reporting_program_type == 'ep'
  end

  def execute(file, user, sibling_execution_id)
    te = test_executions.create!(expected_results: expected_results, artifact: Artifact.new(file: file), user_id: user)
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.c3_test)
    te.sibling_execution_id = sibling_execution_id
    te.save
    te
  end
end
