class TestExecution
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include GlobalID::Identification
  # include Cypress::ErrorCollector

  field :state, :type => Symbol, :default => :pending
  field :expected_results, :type => Hash
  field :reported_results, :type => Hash
  field :qrda_type, :type => String
  field :backtrace, :type => String
  # a sibling test execution is a c3 test execution if the current execution is a c1 or c2 execution. vice versa
  #   and nil if c3 execution does not exist
  field :sibling_execution_id, :type => String

  embeds_many :execution_errors
  has_one :artifact, :autosave => true, :dependent => :destroy
  belongs_to :user
  belongs_to :task, :touch => true

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

    # TODO R2P: change R/P model through all validators
    artifact.each_file do |name, file|
      doc = build_document(file)
      merged_options = options.merge(:file_name => name)
      validators.each do |validator|
        validator.validate(doc, merged_options)
        break unless validator.can_continue
      end
      file_count += 1
    end
    validators.each do |validator|
      execution_errors.concat validator.errors
    end
    conditionally_add_task_specific_errors(file_count)
    execution_errors.only_errors.count.positive? ? fail : pass
  rescue => e
    errored(e)
    logger.error("Encountered an exception in Test Execution #{id}: #{e.message}, backgrace:\n#{e.backtrace}")
  end

  def conditionally_add_task_specific_errors(file_count)
    if (task.is_a?(C1Task) && task.product_test.product.c1_test) && file_count != task.patients.count
      execution_errors.build(:message => "#{task.patients.count} files expected but was #{file_count}",
                             :msg_type => :error, :validator_type => :result_validation, :validator => :smoking_gun)
    end
    task.product_test.build_execution_errors_for_incomplete_checked_criteria(self) if task.is_a?(C1ChecklistTask)
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

  def errored?
    state == :errored
  end

  def incomplete?
    (!passing? && !failing? && !errored?)
  end

  def pass
    self.state = :passed
    save
  end

  def fail
    self.state = :failed
    save
  end

  def errored(e = nil)
    self.state = :errored
    self.backtrace = e.message + "\n" + e.backtrace.join("\n")
    save
  end

  def sibling_execution
    TestExecution.find(sibling_execution_id)
  rescue
    nil
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
    errored? || (sibling_execution && sibling_execution.errored?)
  end

  def incomplete_or_sibling_incomplete?
    incomplete? || (sibling_execution && sibling_execution.incomplete?)
  end
end
