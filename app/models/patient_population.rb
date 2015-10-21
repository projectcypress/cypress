# TestPopulations are subsets of the Master Patient List. Each Test that is executed for a Product uses a TestPopulation
# to keep track of the Records who will be considered in measure calculation.

class PatientPopulation
  include Mongoid::Document
  include HealthDataStandards::CQM

  belongs_to :product_test, index: true
  belongs_to :user, index: true
  has_and_belongs_to_many :records, index: true # rubocop:disable Rails/HasAndBelongsToMany

  field :id, type: String
  field :name, type: String
  field :description, type: String
  field :patient_ids, type: Array

  validates :id, :name, :patient_ids, presence: true

  def self.installed
    PatientPopulation.order_by([['name', :asc]]).to_a
  end
end
