# TestPopulations are subsets of the Master Patient List. Each Test that is executed for a Product uses a TestPopulation
# to keep track of the Records who will be considered in measure calculation.

class PatientPopulation
  include Mongoid::Document
  
  belongs_to :product_test
  has_and_belongs_to_many :records
  
  field :id, type: String
  field :name, type: String
  field :description, type: String
  field :patient_ids, type: Array

  def self.installed
    PatientPopulation.order_by([["name", :asc]]).to_a
  end
  
end
