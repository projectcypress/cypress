class ProgramCriterion
  include Mongoid::Document

  field :criterion_key, type: String
  field :criterion_name, type: String
  field :criterion_description, type: String
  field :criterion_xpath, type: String
  field :cms_conf, type: String
  field :entered_value, type: String
  field :criterion_verified, type: Boolean, default: false
  field :file_name, type: String

  embedded_in :cms_program_test

  def reset_criterion
    self.criterion_verified = false
  end
end
