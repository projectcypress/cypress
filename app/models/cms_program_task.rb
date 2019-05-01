class CMSProgramTask < Task
  include ::Validators

  after_create :initialize_program_specific_fields

  def validators
    @validators = [ProgramCriteriaValidator.new(product_test),
                   ProgramValidator.new(product_test.cms_program),
                   MeasurePeriodValidator.new]
    @validators.concat program_specific_validators
  end

  def program_specific_validators
    return hqr_pi_validators if product_test.cms_program == 'HQR_PI'
    return hqr_iqr_validators if product_test.cms_program == 'HQR_IQR'
    return hqr_pi_iqr_validators if product_test.cms_program == 'HQR_PI_IQR'
    return hqr_iqr_vol_validators if product_test.cms_program == 'HQR_IQR_VOL'
    return cpcplus_validators if product_test.cms_program == 'CPCPLUS'
    return mips_group_validators if product_test.cms_program == 'MIPS_GROUP'
    return mips_indiv_validators if product_test.cms_program == 'MIPS_INDIV'
    return mips_virtual_group_validators if product_test.cms_program == 'MIPS_VIRTUALGROUP'

    []
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

  def mips_group_validators
    ep_validators
  end

  def mips_indiv_validators
    ep_validators
  end

  def mips_virtual_group_validators
    ep_validators
  end

  def eh_validators
    [::Validators::CMSQRDA1HQRSchematronValidator.new(product_test.bundle.version, false),
     ::Validators::EncounterValidator.new,
     ::Validators::QrdaCat1Validator.new(product_test.bundle, false, product_test.c3_test, true, product_test.measures)]
  end

  def ep_validators
    [::Validators::CMSQRDA3SchematronValidator.new(product_test.bundle.version, false),
     ::Validators::QrdaCat3Validator.new(nil, false, true, false, product_test.bundle),
     Cat3PopulationValidator.new]
  end

  def initialize_program_specific_fields
    program_criteria = CMS_IG_CONFIG.select { |_k, v| v['programs'].include? product_test.cms_program }
    program_criteria.each do |criterium_key, criterium_hash|
      description = criterium_hash['description'][product_test.cms_program] || criterium_hash['description'][product_test.reporting_program_type]
      conf = criterium_hash['conf'][product_test.cms_program] || criterium_hash['conf'][product_test.reporting_program_type]
      product_test.program_criteria << ProgramCriterium.new(criterium_key: criterium_key,
                                                            criterium_name: criterium_hash['name'],
                                                            criterium_description: description,
                                                            cms_conf: conf)
    end
  end

  def execute(file, user)
    te = test_executions.create
    te.user = user
    te.artifact = Artifact.new(file: file)
    te.save!
    TestExecutionJob.perform_later(te, self)
    te.save
    te
  end
end
