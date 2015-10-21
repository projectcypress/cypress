class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps

  include HealthDataStandards::CQM

  belongs_to :product, index: true, touch: true
  belongs_to :bundle, index: true
  has_many   :tasks, dependent: :destroy

  field :expected_results, type: Hash
  # this the hqmf id of the measure
  field :measure_id, type: String
  # Test Details
  field :name, type: String
  field :description, type: String

  field :status_message, type: String
  field :state, type: Symbol

  validates :name, presence: true
  validates :product, presence: true
  validates :measure_id, presence: true


  def measures
    HealthDataStandards::CQM::Measure.where({bundle_id: bundle_id, hqmf_id: measure_id})
  end

  def execute(params)
    raise NotImplementedError.new
  end

  def records
    Record.where(test_id: self.id)
  end

  def results
    PatientCache.where("value.test_id"=> self.id).order_by(["value.last" , :asc])
  end
end
