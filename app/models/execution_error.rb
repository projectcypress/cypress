class ExecutionError
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic

  embedded_in :test_execution
  field :message, type: String
  field :msg_type, type: Symbol
  field :measure_id, type: String
  field :validation_type, type: String
  field :validator, type: String
  field :stratification, type: String
  field :location
  field :file_name, type: String
  field :cms, type: Boolean, default: false
  validates :msg_type, presence: true
  validates :message, presence: true

  scope :by_type, ->(type) { where(msg_type: type) }
  scope :by_validation_type, ->(type) { where(validator_type: type) }
  scope :by_file, ->(file) { where(file_name: file) }

  def self.only_errors
    by_type(:error).entries
  end

  def self.only_warnings
    by_type(:warning).entries
  end

  def self.only_cms_warnings
    by_type(:warning).where(cms: true).entries
  end

  def self.non_cms_warnings
    by_type(:warning).where(cms: false).entries
  end

  # only if validator is one of 'CDA SDTC Validator', 'QRDA Cat 1 R3 Validator', 'QRDA Cat 1 Validator', or 'QRDA Cat 3 Validator'
  #   or if validator type is xml_validation
  def self.qrda_errors
    valid_strings = %w(CDA\ SDTC\ Validator QRDA\ Cat\ 1\ R3\ Validator QRDA\ Cat\ 1\ Validator QRDA\ Cat\ 3\ Validator)
    all.select do |execution_error|
      true if (execution_error.has_attribute?('validator') &&
               valid_strings.include?(execution_error[:validator])) ||
              (execution_error.has_attribute?('validator_type') && execution_error[:validator_type] == :xml_validation)
    end
  end

  # only if validator is one of 'Cat 1 Measure ID Validator' or 'Cat 3 Measure ID Validator'
  #   or if validator type is result_validation
  def self.reporting_errors
    all.select do |execution_error|
      true if (execution_error.has_attribute?('validator') &&
               %w(Cat\ 1\ Measure\ ID\ Validator Cat\ 3\ Measure\ ID\ Validator).include?(execution_error[:validator])) ||
              (execution_error.has_attribute?('validator_type') && execution_error[:validator_type] == :result_validation)
    end
  end

  # only if validator type is submission_validation
  def self.submission_errors
    all.select do |execution_error|
      true if execution_error.has_attribute?('validator_type') && execution_error[:validator_type] == :submission_validation
    end
  end
end
