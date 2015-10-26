class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include HealthDataStandards::CQM

  belongs_to :product, index: true, touch: true
  belongs_to :bundle, index: true

  has_many :tasks, :dependent => :destroy

  field :expected_results, type: Hash
  # this the hqmf id of the measure
  field :measure_id, type: String
  # Test Details
  field :name, type: String
  field :description, type: String

  field :status_message, type: String
  field :state, :type => Symbol, :default => :pending
  field :effective_date, type: Integer
  validates :name, presence: true
  validates :product, presence: true
  validates :measure_id, presence: true
  validates :effective_date, presence: true
  validates :bundle_id, presence: true

  after_create :calculate

  def calculate
    MeasureEvaluationJob.perform_later(self, {})
  end

  def measures
    HealthDataStandards::CQM::Measure.where(bundle_id: bundle_id, hqmf_id: measure_id)
  end

  def records
    Record.where(test_id: id)
  end

  def results
    PatientCache.where('value.test_id' => id).order_by(['value.last', :asc])
  end

  def ready
    self.state = :ready
    save
  end
end
