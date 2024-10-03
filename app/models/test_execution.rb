# frozen_string_literal: true

class TestExecution
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include GlobalID::Identification
  # include Cypress::ErrorCollector

  field :state, type: Symbol, default: :pending
  field :expected_results, type: Hash
  field :reported_results, type: Hash
  field :qrda_type, type: String
  field :backtrace, type: String
  field :error_summary, type: String
  # a sibling test execution is a c3 test execution if the current execution is a c1 or c2 execution. vice versa
  #   and nil if c3 execution does not exist
  field :sibling_execution_id, type: String

  embeds_many :execution_errors
  has_one :artifact, dependent: :destroy
  belongs_to :user
  belongs_to :task, touch: true

  before_save :verify_artifact

  def verify_artifact
    artifact&.save
  end

  def build_document(file)
    doc = Nokogiri::XML(file)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    doc
  end

  # I dont think this belongs here and it will need to eventually be moved to a
  # more approperiate location
  def validate_artifact(validators, artifact, options = {})
    total_files = artifact.count
    validated_files = 0
    validation_tracker = tracker
    # TODO: R2P: change R/P model through all validators
    file_count = artifact.count do |name, file|
      doc = build_document(file)
      validators.each do |validator|
        validator.validate(doc, options.merge!(file_name: name))
        break unless validator.can_continue
      end
      validation_tracker&.log("#{validated_files += 1} of #{total_files} files validated")
      true
    end
    validators.each do |validator|
      execution_errors.concat validator.errors
    end
    conditionally_add_task_specific_errors(file_count)
    execution_errors.only_errors.count.positive? ? fail : pass
  rescue StandardError => e
    errored(e, options)
    logger.error("Encountered an exception in Test Execution #{id}: #{e.message}, backgrace:\n#{e.backtrace}")
  end

  def conditionally_add_task_specific_errors(file_count)
    # Limit translation warnings when multiple files are being evaluated to avoid information overload.
    limit_translation_warnings(execution_errors.only_warnings) if file_count > 1
    if (task.is_a?(C1Task) && task.product_test.product.c1_test) && file_count != task.patients.count
      execution_errors.build(message: "#{task.patients.count} files expected but was #{file_count}",
                             msg_type: :error, validator_type: :result_validation, validator: :smoking_gun)
    end
    task.product_test.build_execution_errors_for_incomplete_checked_criteria(self) if task.is_a?(C1ChecklistTask)
    task.product_test.build_execution_errors_for_incomplete_cms_criteria(self) if task.is_a?(CMSProgramTask)
  end

  def passing?
    state == :passed
  end

  def failing?
    state == :failed
  end

  def errored?
    state == :errored
  end

  def incomplete?
    !passing? && !failing? && !errored?
  end

  def pass
    self.state = :passed
    save
  end

  def fail
    self.state = :failed
    save
  end

  def errored(error = nil, options = {})
    self.state = :errored
    self.backtrace = "#{error.message}\n#{error.backtrace.join("\n")}"
    self.error_summary = "Errored validating #{options[:file_name]}: #{error.message} on #{error.backtrace.first.remove(Rails.root.to_s)}"
    save
  end

  def sibling_execution
    TestExecution.find(sibling_execution_id)
  rescue StandardError
    nil
  end

  def tracker
    Tracker.where('options.test_execution_id' => id).first
  end

  def status
    return 'passing' if passing?
    return 'failing' if failing?
    return 'errored' if errored?

    'incomplete'
  end

  # returns combined status including c3 test execution
  # returns passing if both passing, incomplete if either incomplete, failing if both complete and at least one failing
  def status_with_sibling
    sibling = sibling_execution
    return status unless sibling
    return status if status == sibling.status
    return 'incomplete' if incomplete? || sibling.incomplete?
    return 'failing' if failing? || sibling.failing?
    return 'errored' if errored? || sibling.errored?

    'failing' # failing if status's do not match
  end

  def last_updated_with_sibling
    sibling = sibling_execution
    return updated_at unless sibling

    [updated_at, sibling.updated_at].max
  end

  # checks
  def executions_pending?
    c3_execution = sibling_execution
    return state == :pending unless c3_execution

    state == :pending || c3_execution.state == :pending
  end

  def errored_or_sibling_errored?
    errored? || sibling_execution&.errored?
  end

  def incomplete_or_sibling_incomplete?
    incomplete? || sibling_execution&.incomplete?
  end

  # If the root and translation codes are from the same valueset(s), the warning will be removed
  def limit_translation_warnings(warnings)
    task_oids = task.measures.map(&:valueset_oids).flatten
    vs_map = {}
    warnings.each do |warning|
      message_array = warning.message.split
      next unless message_array[0] == 'Translation'

      codes = codes_from_message(message_array)
      # The first code in the message will be the translation code
      trans_code = codes[0]
      # The second code in the message will be the root code
      root_code = codes[1]
      # Collect all of the valuesets (relevant to the task) the root code is part of
      vs_map[root_code] = (valuesets_for_code(root_code) & task_oids).sort if vs_map[root_code].nil?
      # Collect all of the valuesets (relevant to the task) the translation code is part of
      vs_map[trans_code] = (valuesets_for_code(trans_code) & task_oids).sort if vs_map[trans_code].nil?

      # If the valuesets match, the warning can be removed, there should be not impact to calculations
      warning.destroy if vs_map[root_code] == vs_map[trans_code]
    end
  end

  # Given a split warning message, return code values.  codes always have the following convention code:code_system
  def codes_from_message(message_array)
    message_array.collect { |st| st.split(':')[1] if st.include?(':') }.compact
  end

  def valuesets_for_code(code)
    task.bundle.value_sets.only(:oid).where('concepts.code': code).map(&:oid)
  end
end
