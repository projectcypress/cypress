# frozen_string_literal: true

class CMSProgramTest < ProductTest
  field :cms_program, type: String
  field :reporting_program_type, type: String
  embeds_many :program_criteria, class_name: 'ProgramCriterion'
  accepts_nested_attributes_for :program_criteria, allow_destroy: true

  # List of cms programs
  validates :cms_program, inclusion: %w[HQR_PI HQR_IQR HQR_PI_IQR HQR_IQR_VOL
                                        CPCPLUS PCF MIPS_INDIV MIPS_GROUP MIPS_VIRTUALGROUP MIPS_APMENTITY
                                        MIPS_APP1_INDIV MIPS_APP1_GROUP MIPS_APP1_APMENTITY HL7_Cat_I HL7_Cat_III]

  after_create do |product_test|
    create_tasks
    product_test.ready
    save!
  end

  def create_tasks
    CMSProgramTask.new(product_test: self).save!
  end

  def update_with_program_tests(program_test_params)
    update(program_test_params)
    # On update, reset the program criteria checklist
    program_criteria.each(&:reset_criterion)
    save!
  end

  def expected_measures
    # If measures are limited by program, expected measures will be a subset of all of the measure ids
    if CMS_IG_CONFIG['Program Specific Measures'][cms_program]
      CMS_IG_CONFIG['Program Specific Measures'][cms_program][bundle.major_version] & measure_ids
    else
      measure_ids
    end
  end

  # After a test execution is complete, add error messages for each criterion that is not found
  def build_execution_errors_for_incomplete_cms_criteria(execution)
    program_criteria.each do |crit|
      next if crit.criterion_verified

      msg_type = crit.criterion_optional ? :warning : :error
      msg = if msg_type == :warning
              "Warning - #{crit.criterion_name} not complete"
            else
              "#{crit.criterion_name} not complete"
            end
      execution.execution_errors.build(message: msg, msg_type: msg_type, validator: 'Validators::ProgramCriteriaValidator')
    end
  end
end
