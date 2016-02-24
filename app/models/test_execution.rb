class TestExecution
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include GlobalID::Identification

  field :state, :type => Symbol, :default => :pending
  field :expected_results, type: Hash
  field :reported_results, type: Hash
  field :qrda_type, type: String
  # a sibling test execution is a c3 test execution if the current execution is a c1 or c2 execution. vice versa
  #   and nil if c3 execution does not exist
  field :sibling_execution_id, type: String

  embeds_many :execution_errors
  has_one :artifact, :autosave => true, :dependent => :destroy
  belongs_to :task, touch: true

  def build_document(file)
    doc = Nokogiri::XML(file)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    doc
  end

  # I dont think this belongs here and it will need to eventually be moved to a
  # more approperiate location
  def validate_artifact(validators, artifact, options = {})
    file_count = 0

    artifact.each_file do |name, file|
      doc = build_document(file)
      merged_options = options.merge(file_name: name)
      validators.each do |validator|
        validator.validate(doc, merged_options)
        break unless validator.can_continue
      end
      file_count += 1
    end
    validators.each do |validator|
      execution_errors.concat validator.errors
    end
    # only run for Cat1 tests
    if task._type == 'C1Task' && file_count != task.records.count
      execution_errors.build(:message => "#{task.records.count} files expected but was #{file_count}",
                             :msg_type => :error, :validator_type => :result_validation)
    end
    (only_errors.count > 0) ? fail : pass
  end

  def only_errors
    execution_errors.by_type(:error).entries
  end

  def only_warnings
    execution_errors.by_type(:warning).entries
  end

  # Get the expected result for a particular measure
  def expected_result(measure)
    (expected_results || product_test.expected_results || {})[measure.key] || {}
  end

  # Get the expected result for a particular measure
  def reported_result(measure)
    (reported_results || {})[measure.key] || {}
  end

  def passing?
    state == :passed
  end

  def failing?
    state == :failed
  end

  def incomplete?
    (!passing? && !failing?)
  end

  def pass
    self.state = :passed
    save
  end

  def fail
    self.state = :failed
    save
  end

  def sibling_execution
    TestExecution.find(sibling_execution_id)
  rescue
    nil
  end

  def c1_task?
    return false unless task.has_attribute?(:_type)
    task._type == 'C1Task'
  end

  # only if validator is one of 'CDA SDTC Validator', 'QRDA Cat 1 R3 Validator', 'QRDA Cat 1 Validator', or 'QRDA Cat 3 Validator'
  #   or if validator type is xml_validation
  def qrda_errors
    valid_strings = %w(CDA\ SDTC\ Validator QRDA\ Cat\ 1\ R3\ Validator QRDA\ Cat\ 1\ Validator QRDA\ Cat\ 3\ Validator)
    execution_errors.select do |execution_error|
      true if (execution_error.has_attribute?('validator') &&
               valid_strings.include?(execution_error[:validator])) ||
              (execution_error.has_attribute?('validator_type') && execution_error[:validator_type] == :xml_validation)
    end
  end

  # only if validator is one of 'Cat 1 Measure ID Validator' or 'Cat 3 Measure ID Validator'
  #   or if validator type is result_validation
  def reporting_errors
    execution_errors.select do |execution_error|
      true if (execution_error.has_attribute?('validator') &&
               %w(Cat\ 1\ Measure\ ID\ Validator Cat\ 3\ Measure\ ID\ Validator).include?(execution_error[:validator])) ||
              (execution_error.has_attribute?('validator_type') && execution_error[:validator_type] == :result_validation)
    end
  end

  # only if validator type is submission_validation
  def submission_errors
    execution_errors.select do |execution_error|
      true if execution_error.has_attribute?('validator_type') && execution_error[:validator_type] == :submission_validation
    end
  end
end
