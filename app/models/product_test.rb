class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps
  include AASM

  belongs_to :product, index: true, touch: true
  has_one :patient_population
  has_many :test_executions, dependent: :destroy
  belongs_to :user, index: true
  belongs_to :bundle, index: true

  embeds_many :notes, inverse_of: :product_test

  # Test Details
  field :name, type: String
  field :description, type: String
  field :effective_date, type: Integer
  field :measure_ids, type: Array
  field :parent_cat3_ids, type: Array
  field :expected_results, type: Hash
  field :status_message, type: String
  field :state, :type => Symbol

  validates_presence_of :name
  validates_presence_of :effective_date
  validates_presence_of :bundle_id

  scope :order_by_type, -> { order_by(_type: desc) }

  aasm column: :state do
    state :pending, :initial => true
    state :ready, :after_enter => :ready_callback
    state :errored, :after_enter => :error_callback

    event :ready do
      transitions :to => :ready
    end

    event :errored do
      transitions :to => :error
    end

  end

  def ready_callback
    self.status_message ="Ready"
    self.save
  end

  def error_callback
    self.status_message ="Error"
    self.save
  end

  def self.inherited(child)
    child.instance_eval do
      def model_name
        ProductTest.model_name
      end
    end
    super
  end

  def last_execution_date

  end

  # Returns true if this ProductTests most recent TestExecution is passing
  def execution_state
    return :pending if self.test_executions.empty?

    self.test_executions.ordered_by_date.first.state
  end

  def passing?
    execution_state == :passed
  end

  # Return all measures that are selected for this particular ProductTest
  def measures
    return [] if !measure_ids
    self.bundle.measures.in(:hqmf_id => measure_ids).order_by([[:hqmf_id, :asc],[:sub_id, :asc]])
  end


  def records
    Record.where(:test_id => self.id).order_by([:last , :asc])
  end

  def delete
    # Gather all records and their IDs so we can delete them along with every associated entry in the patient cache
    records = Record.where(:test_id => self.id)
    record_ids = records.map { _id }
    MONGO_DB.collection('patient_cache').remove({'value.patient_id' => {"$in" => record_ids}})
    records.destroy
    self.destroy
  end

  # Get the expected result for a particular measure
  def expected_result(measure)
   (expected_results || {})[measure.key]
  end

  # Used for downloading and e-mailing the records associated with this test.
   #
   # Returns a file that represents the test's patients given the requested format.
  def generate_records_file(format)
     file = Tempfile.new("patients-#{Time.now.to_i}")
     patients = Record.where("test_id" => self.id)
     Cypress::PatientZipper.zip(file, patients, format.to_sym)

     file
  end

  def start_date
    Time.at(self.bundle['measure_period_start']).gmtime
  end

  def end_date
    Time.at(effective_date).gmtime
  end


  def results
    Result.where("value.test_id"=> self.id).order_by(["value.last" , :asc])
  end

  def measure_results(measure)
      self.results.where({"value.hqmf_id" => measure.hqmf_id, })
  end

  def destroy
    self.results.destroy
    self.records.destroy
    Mongoid.default_session["query_cache"].where({"test_id" => self.id}).remove_all
    super
  end

  def delete(options = {})
     self.results.destroy
     self.records.destroy
     Mongoid.default_session["query_cache"].where({"test_id" => self.id}).remove_all
    super
  end

end
