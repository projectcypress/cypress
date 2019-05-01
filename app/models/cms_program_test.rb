class CMSProgramTest < ProductTest
  field :cms_program, type: String
  field :reporting_program_type, type: String
  embeds_many :program_criteria
  accepts_nested_attributes_for :program_criteria, allow_destroy: true

  validates :cms_program, inclusion: %w[HQR_PI HQR_IQR HQR_PI_IQR HQR_IQR_VOL CPCPLUS MIPS_INDIV MIPS_GROUP MIPS_VIRTUALGROUP]

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
    program_criteria.each(&:reset_criteria)
    save!
  end

  def build_execution_errors_for_incomplete_cms_criteria(execution)
    program_criteria.each do |crit|
      next if crit.criterium_verified

      msg = "#{crit.criterium_name} not complete"
      # did not add ":validator_type =>", not sure if this will be an issue in execution show
      execution.execution_errors.build(message: msg, msg_type: :error, validator: :qrda_cat1)
    end
  end
end
