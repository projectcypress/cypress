class ProductTest
  include Mongoid::Document

  belongs_to :product
  has_one :patient_population
  has_many :test_executions, dependent: :delete
  belongs_to :user

  embeds_many :notes, inverse_of: :product_test

  # Test Details
  field :name, type: String
  field :description, type: String
  field :effective_date, type: Integer
  field :measure_ids, type: Array
  field :expected_results, type: Hash
  
  validates_presence_of :name
  validates_presence_of :effective_date

  
  state_machine :state, :initial => :pending  do      
    event :ready do
      transition all => :ready
    end  
    
    event :errored do
      transition all => :error
    end
    
  end
  
  

  # Returns true if this ProductTests most recent TestExecution is passing
  def execution_state
    return :pending if self.test_executions.empty?   
    most_recent_execution = self.test_executions.ordered_by_date.first.state
  end
  

  
  # Return all measures that are selected for this particular ProductTest
  def measures
    return [] if !measure_ids
    self.measure_ids.collect do |measure_id|
      Measure.where(id: measure_id).order_by([[:sub_id, :asc]]).all()
    end.flatten
  end
  

  def records
    Record.where(:test_id => self.id)
  end

  def destroy
    # Gather all records and their IDs so we can delete them along with every associated entry in the patient cache
    records = Record.where(:test_id => self.id)
    record_ids = records.map { _id }
    MONGO_DB.collection('patient_cache').remove({'value.patient_id' => {"$in" => record_ids}})
    records.destroy
    self.delete
  end
  
  
  
  # Used for downloading and e-mailing the records associated with this test.
   #
   # Returns a file that represents the test's patients given the requested format.
   def generate_records_file(format)
     file = Tempfile.new("patients-#{Time.now.to_i}")
     patients = Record.where("test_id" => self.id)

     if format == 'csv'
       Cypress::PatientZipper.flat_file(file, patients)
     else
       Cypress::PatientZipper.zip(file, patients, format.to_sym)
     end

     file
   end
 
end