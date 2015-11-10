class TestExecution
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  field :state, :type => Symbol, :default => :pending
  field :expected_results, type: Hash
  field :reported_results, type: Hash

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
    (count_errors > 0) ? fail : pass
  end

  def count_errors
    execution_errors.where(:msg_type => :error).count
  end

  def count_warnings
    execution_errors.where(:msg_type => :warning).count
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
end
