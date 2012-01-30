# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  
  has_and_belongs_to_many :patient_population
  has_many :test_results
  
  field :measures, type: Hash
end