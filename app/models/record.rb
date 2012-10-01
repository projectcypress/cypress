# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  
  has_and_belongs_to_many :patient_population
   
  field :measures, type: Hash
  field :race
  field :ethnicity
  
end