class ProgramCriterium
  include Mongoid::Document

  field :criterium_key, type: String
  field :criterium_name, type: String
  field :criterium_description, type: String
  field :criterium_xpath, type: String
  field :cms_conf, type: String
  field :entered_value, type: String
  field :criterium_verified, type: Boolean, default: false
  field :file_name, type: String

  embedded_in :cms_program_test

  def reset_criteria
    self.criterium_verified = false
  end
end
