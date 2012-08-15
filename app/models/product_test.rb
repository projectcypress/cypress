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

  field :population_creation_job, type: String
  field :result_calculation_jobs, type: Hash
  field :expected_results, :type Hash
  
  validates_presence_of :name
  validates_presence_of :effective_date


  def self.generate_records_for_measures(measures_ids)
     raise NotImplementedError
  end
  
  def self.generate_expected_results
    
  end
  
  
  def self.measures
    raise NotImplementedError
  end
  

  # Returns true if this ProductTests most recent TestExecution is passing
  def execution_status
    return :pending if self.test_executions.empty?   
    most_recent_execution = self.ordered_executions.first.status
  end
  

  
  # Return all measures that are selected for this particular ProductTest
  def measure_defs
    return [] if !measure_ids
    
    self.measure_ids.collect do |measure_id|
      Measure.where(id: measure_id).order_by([[:sub_id, :asc]]).all()
    end.flatten
  end
  



  def destroy
    # Gather all records and their IDs so we can delete them along with every associated entry in the patient cache
    records = Record.where(:test_id => self.id)
    record_ids = records.map { _id }
    MONGO_DB.collection('patient_cache').remove({'value.patient_id' => {"$in" => record_ids}})
    records.destroy
    self.delete
  end
  
 
end