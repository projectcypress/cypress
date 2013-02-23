# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  
  has_and_belongs_to_many :patient_population
  #belongs_to :bundle 
  field :measures, type: Hash
  field :race
  field :ethnicity
  
  index :last => 1

  def bundle 
  	Bundle.find(self["bundle_id"])
  end 
end