class TestExecution
  include Mongoid::Document
  include Mongoid::Timestamps
<<<<<<< HEAD

  belongs_to :product_test
end
=======
  include Mongoid::Attributes::Dynamic

  field :state, type: Symbol, default: :pending
  field :expected_results, type: Hash
  field :reported_results, type: Hash

  embeds_many :execution_errors
  has_one :artifact, autosave: true, dependent: :destroy
  belongs_to :task

  # I dont think this belongs here and it will need to eventually be moved to a
  # more approperiate location
  def validate_artifact(validators, artifact)
    file_count = 0

    artifact.each_file do |name, file|
      doc = Nokogiri::XML(file)
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")

      validators.each do |validator|
        validator.validate(doc, {file_name: name})
        if validator.is_a? ::Validators::ExpectedResultsValidator
          self.reported_results = validator.reported_results
        end
      end
      file_count += 1
    end

    validators.each do |v|
      self.execution_errors.concat v.errors
    end
    #only run for Cat1 tests
    if self.task._type == "C1Task"
      if file_count != self.task.records.count
        self.execution_errors.build(message: "#{self.task.records.count} files expected but was #{file_count}", msg_type: :error, validator_type: :result_validation)
      end
    end
    (self.count_errors > 0) ? self.fail : self.pass
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

  def pass
    state= :passed
    save
  end

  def fail 
    state= :failed
    save
  end


end
>>>>>>> pulling over fixture and test data from master branch.  Modified test structure so there is a single product_test that has multiple tasks and each task can have multiple executions.  This will allow for multiple c4 filter tests to be applied to the same ProductTest.  Implmented C1 and C3 tasks based off current Cypress QRDA and Calculated product tests.
