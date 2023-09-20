# frozen_string_literal: true

class C3Cat1Task < Task
  def validators
    # not using the "calculating" smoking gun validator here
    # because we only want the record (patient) inclusion test from the regular version
    @validators = [::Validators::SmokingGunValidator.new(product_test.measures, product_test.patients, product_test.id,
                                                         suppress_errors: true, validate_inclusion_only: true),
                   ::Validators::MeasurePeriodValidator.new,
                   ::Validators::CoreClinicalDataElementValidator.new(product_test.measures),
                   ::Validators::QrdaCat1Validator.new(product_test.bundle, true, true, product_test.c1_test, product_test.measures)]
    @validators << cms_cat1_schematron_validator if product_test.bundle.cms_schematron
    @validators << cms_program_validator
    @validators
  end

  def cms_program_validator
    if !APP_CONSTANTS['oqr_measures'].intersection(measure_ids).blank?
      ::Validators::ProgramValidator.new(['HQR_OQR'])
    elsif product_test.hybrid_measures?
      ::Validators::ProgramValidator.new(['HQR_IQR'])
    else
      ::Validators::ProgramValidator.new(%w[HQR_IQR HQR_PI_IQR HQR_PI])
    end
  end

  def cms_cat1_schematron_validator
    measure = product_test.measures[0]
    if measure.reporting_program_type == 'eh'
      # If product is not for 21st Centutry Cures, then CMS errors are treated as warnings
      ::Validators::CMSQRDA1HQRSchematronValidator.new(product_test.bundle.version, as_warnings: !product_test.cures_update)
    else
      # If product is not for 21st Centutry Cures, then CMS errors are treated as warnings
      ::Validators::CMSQRDA1PQRSSchematronValidator.new(product_test.bundle.version, as_warnings: !product_test.cures_update)
    end
  end

  def execute(file, user, sibling_execution_id)
    te = test_executions.new(expected_results:, artifact: Artifact.new(file:), user_id: user)
    te.save!
    TestExecutionJob.perform_later(te, self, validate_reporting: product_test.c3_test)
    te.sibling_execution_id = sibling_execution_id
    te.save
    te
  end
end
