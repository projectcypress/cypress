class CMSProgramTest < ProductTest
  field :cms_program, type: String
  field :reporting_program_type, type: String
  embeds_many :program_criteria, class_name: 'ProgramCriterion'
  accepts_nested_attributes_for :program_criteria, allow_destroy: true

  # List of cms programs
  validates :cms_program, inclusion: %w[HQR_PI HQR_IQR HQR_PI_IQR HQR_IQR_VOL CPCPLUS MIPS_INDIV MIPS_GROUP MIPS_VIRTUALGROUP HL7_Cat_I HL7_Cat_III]

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

  # After a test execution is complete, add error messages for each criterion that is not found
  def build_execution_errors_for_incomplete_cms_criteria(execution)
    program_criteria.each do |crit|
      next if crit.criterion_verified

      msg = "#{crit.criterion_name} not complete"
      execution.execution_errors.build(message: msg, msg_type: :error, validator: 'Validators::ProgramCriteriaValidator')
    end
  end
end
