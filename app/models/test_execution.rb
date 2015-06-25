
class TestExecution
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::Attributes::Dynamic
  include AASM

  has_one :artifact, autosave: true, dependent: :destroy

  belongs_to :product_test, index: true, touch: true

  embeds_many :execution_errors
  field :required_modules, type: Array
  field :expected_results, type: Hash
  field :reported_results, type: Hash
  field :matched_results, type: Hash

  field :status, type: Symbol
  field :state, type: Symbol
  field :file_ids, type: Array

  scope :ordered_by_date, -> { order_by(created_at: :desc) }
  scope :order_by_state, -> { order_by(state: :asc) }

  index({product_test_id: 1, created_at: -1})

  aasm column: :state do
    state :pending, :initial => true
    state :failed
    state :passed
    state :force_pass
    state :force_fail
    state :reset

    event :failed do
      transitions :from => :pending, :to => :failed
    end

    event :pass do
      transitions :from => :pending, :to => :passed
    end

    event :force_pass do
      transitions :to => :passed
    end

    event :force_fail do
      transitions :to => :failed
    end

    event :reset do
      transitions :to => :pending
    end

  end

  def validate_artifact(validators)
    file_count = 0

    self.artifact.each_file do |name, file|
      doc = Nokogiri::XML(file)
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")

      validators.each do |validator|
        validator.validate(doc, {file_name: name})
      end
      file_count += 1
    end

    validators.each do |v|
      self.execution_errors.concat v.errors
    end
    #only run for Cat1 tests
    if self.product_test._type == "QRDAProductTest"
      if file_count != self.product_test.records.count
  self.execution_errors.build(message: "#{self.product_test.records.count} files expected but was #{file_count}", msg_type: :error, validator_type: :result_validation)
      end
    end
    (self.count_errors > 0) ? self.failed : self.pass
  end

  def execution_date
     self.created_at || Time.at(self['execution_date'])
  end

  def count_errors
    execution_errors.where({:msg_type=>:error}).count
  end

  def count_warnings
     execution_errors.where({:msg_type=>:warning}).count
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
    self.state == :passed
  end

  def failing?
    self.state == :failed
  end

  def incomplete?
    (!passing? && !failing?)
  end

  def files
    return [] if self.file_ids.nil? || self.file_ids.length == 0
     Cypress::ArtifactManager.get_artifacts(self.file_ids)
  end


  def passing_measures
     m_ids = execution_errors.collect {|ee| "#{ee.measure_id}-#{ee.stratification}"}
     m_ids += execution_errors.collect {|ee| "#{ee.measure_id}"} # here for older tests
     m_ids.flatten!
     m_ids.compact!
     m_ids.uniq!
     mes = product_test.measures.collect{|m|
       m_ids.index("#{m.hqmf_id}-#{m.population_ids['stratification']}") || m_ids.index(m.key)  ? nil : m }# look for m.key for older test executions
     mes.compact!
     mes.sort
  end

  def failing_measures
     m_ids = execution_errors.collect {|ee| "#{ee.measure_id}-#{ee.stratification}"}
     m_ids += execution_errors.collect {|ee| "#{ee.measure_id}"} # here for older tests
     m_ids.flatten!
     m_ids.compact!
     m_ids.uniq!
     mes = product_test.measures.collect{|m|
        m_ids.index("#{m.hqmf_id}-#{m.population_ids['stratification']}") || m_ids.index(m.key) ? m : nil } # look for m.key for older test executions
     mes.compact!
     mes.sort
  end

  def measure_passed?(measure)
    passing_measures.find{|m| m.id == measure.id}
  end

end
