# frozen_string_literal: true

class CMSProgramTask < Task
  include ::Validators

  after_create :initialize_program_specific_fields

  def validators
    # Valiators that are common across all tests
    @validators = [ProgramCriteriaValidator.new(product_test),
                   ProgramValidator.new(product_test.cms_program),
                   MeasurePeriodValidator.new]
    # Each program may have program specific validations add them
    @validators.concat program_specific_validators
    # If the CMSProgramTask is for HL7 validation, only include QRDA validation
    @validators = hl7_validators if %w[HL7_Cat_I HL7_Cat_III].include? product_test.cms_program
    @validators
  end

  # Each cms program may have program specific validations
  def program_specific_validators
    return eh_program_specific_validators if product_test.reporting_program_type == 'eh'
    return ep_program_specific_validators if product_test.reporting_program_type == 'ep'

    []
  end

  def eh_program_specific_validators
    return hqr_pi_validators if product_test.cms_program == 'HQR_PI'
    return hqr_iqr_validators if product_test.cms_program == 'HQR_IQR'
    return hqr_pi_iqr_validators if product_test.cms_program == 'HQR_PI_IQR'
    return hqr_iqr_vol_validators if product_test.cms_program == 'HQR_IQR_VOL'

    []
  end

  def ep_program_specific_validators
    return cpcplus_validators if product_test.cms_program == 'CPCPLUS'
    return pcf_validators if product_test.cms_program == 'PCF'
    return mips_group_validators if product_test.cms_program == 'MIPS_GROUP'
    return mips_indiv_validators if product_test.cms_program == 'MIPS_INDIV'
    return mips_virtual_group_validators if product_test.cms_program == 'MIPS_VIRTUALGROUP'
    return mips_apm_entity_validators if product_test.cms_program == 'MIPS_APMENTITY'
    return mips_app_indiv_validators if product_test.cms_program == 'MIPS_APP1_INDIV'
    return mips_app_group_validators if product_test.cms_program == 'MIPS_APP1_GROUP'
    return mips_app_entity_validators if product_test.cms_program == 'MIPS_APP1_APMENTITY'

    []
  end

  def hl7_validators
    if product_test.reporting_program_type == 'eh'
      # ProgramCriteriaValidator is how the measure calculation is being called. Add it as well to Cat I files
      [::Validators::QrdaCat1Validator.new(product_test.bundle, false, product_test.c3_test, true), ProgramCriteriaValidator.new(product_test)]
    else
      [::Validators::QrdaCat3Validator.new(nil, false, true, false, product_test.bundle), Cat3PopulationValidator.new(product_test.measure_ids)]
    end
  end

  def hqr_pi_validators
    eh_validators
  end

  def hqr_iqr_validators
    eh_validators
  end

  def hqr_pi_iqr_validators
    eh_validators
  end

  def hqr_iqr_vol_validators
    eh_validators
  end

  def cpcplus_validators
    ep_validators
  end

  def pcf_validators
    ep_validators
  end

  def mips_group_validators
    # For MIPS submissions, CMS EHR Certification ID is only required if Promoting Interoperability is included
    [EHRCertificationIdValidator.new].concat ep_validators
  end

  def mips_indiv_validators
    # For MIPS submissions, CMS EHR Certification ID is only required if Promoting Interoperability is included
    [EHRCertificationIdValidator.new].concat ep_validators
  end

  def mips_virtual_group_validators
    # For MIPS submissions, CMS EHR Certification ID is only required if Promoting Interoperability is included
    [EHRCertificationIdValidator.new].concat ep_validators
  end

  def mips_apm_entity_validators
    # Unlike other MIPS submissions, the Promoting Interoperability should not be present for APMENTITY
    ep_validators
  end

  def mips_app_indiv_validators
    ep_validators
  end

  def mips_app_group_validators
    ep_validators
  end

  def mips_app_entity_validators
    ep_validators
  end

  # Common validators for EH programs
  def eh_validators
    [::Validators::CMSQRDA1HQRSchematronValidator.new(product_test.bundle.version, as_warnings: false),
     ::Validators::EncounterValidator.new,
     ::Validators::CoreClinicalDataElementValidator.new(product_test.measures),
     ::Validators::QrdaCat1Validator.new(product_test.bundle, false, product_test.c3_test, true)]
  end

  # Common validators for EP programs
  def ep_validators
    [::Validators::CMSQRDA3SchematronValidator.new(product_test.bundle.version, as_warnings: false),
     ::Validators::QrdaCat3Validator.new(nil, false, true, false, product_test.bundle),
     Cat3PopulationValidator.new(product_test.measure_ids)]
  end

  # Program Specific fields to be added to checklist portion of test
  def initialize_program_specific_fields
    # Program Specific fields are in the CMS_IG_CONFIG file
    program_criteria = CMS_IG_CONFIG['Program Criterion'].select { |_k, v| v['programs'].include? product_test.cms_program }
    program_criteria.each do |criterion_key, criterion_hash|
      description = criterion_hash['description'][product_test.cms_program] || criterion_hash['description'][product_test.reporting_program_type]
      conf = criterion_hash['conf'][product_test.cms_program] || criterion_hash['conf'][product_test.reporting_program_type]
      is_optional = criterion_hash['optional'] ? true : false
      product_test.program_criteria << ProgramCriterion.new(criterion_key: criterion_key,
                                                            criterion_name: criterion_hash['name'],
                                                            criterion_description: description,
                                                            criterion_optional: is_optional,
                                                            cms_conf: conf)
    end
  end

  def execute(file, user)
    te = test_executions.create
    te.user = user
    te.artifact = Artifact.new(file: file)
    te.save!
    CMSTestExecutionJob.perform_later(te, self)
    te.save
    te
  end
end
