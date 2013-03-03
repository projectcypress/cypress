# The Record model is an extension of Record as defined by HealthDataStandards.

class Record
  include Mongoid::Document
  
  has_and_belongs_to_many :patient_population
  #belongs_to :bundle 
  field :measures, type: Hash
  field :race
  field :ethnicity
  
  index :last => 1
  index :bundle_id => 1

  def bundle 
    if !self["bundle_id"].nil? 
  	  Bundle.find(self["bundle_id"])
    elsif !self["test_id"].nil?
      ProductTest.find(self["test_id"]).bundle
    end
  end 
end