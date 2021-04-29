class C3Cat3Task < Task
  def validators
    @validators = [::Validators::MeasurePeriodValidator.new,
                   ::Validators::QrdaCat3Validator.new(product_test.expected_results, true, true, product_test.c2_test, product_test.bundle)]
    cms_cat3_schematron_validator if product_test.bundle.cms_schematron
    @validators
  end

  def cms_cat3_schematron_validator
    measure = product_test.measures[0]
    return unless measure.reporting_program_type == 'ep'

    # If product is not for 21st Centutry Cures, then CMS errors are treated as warnings
    @validators << ::Validators::CMSQRDA3SchematronValidator.new(product_test.bundle.version, as_warnings: !product_test.cures_update)
  end

  def execute(file, user, sibling_execution_id)
    te = test_executions.new(expected_results: expected_results, artifact: Artifact.new(file: file), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.c3_test)
    te.sibling_execution_id = sibling_execution_id
    te.save
    te
  end
end
