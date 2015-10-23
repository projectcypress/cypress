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
  field :state, type: Symbol

  field :status_message, type: String
  field :effective_date, type: Integer
  validates :name, presence: true
  validates :product, presence: true
  validates :measure_id, presence: true
  validates :effective_date, presence: true
  validates :bundle_id, presence: true

  after_create :generate_records

  def generate_records
    ids = PatientCache.where('value.measure_id' => measure_id, 'value.IPP' => { '$gt' => 0 }).collect { |pcv| pcv.value.medical_record_id }
    ids.uniq!
    random_ids = Record.all.pluck('medical_record_number').uniq
    Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => ids, 'randomization_ids' =>  random_ids, 'randomize_names' => true).perform
    calculate
  end

  def calculate
    MeasureEvaluationJob.perform_later(self, {})
  end

  def measures
    Measure.where(bundle_id: bundle_id, hqmf_id: measure_id)
  end

  def execute(_params)
    fail NotImplementedError
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

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      total = tasks.count
      if tasks_failing.count > 0
        'failing'
      elsif tasks_passing.count == total && total > 0
        'passing'
      else
        'incomplete'
      end
    end
  end

  def tasks_passing
    Rails.cache.fetch("#{cache_key}/tasks_passing") do
      tasks.select { |task| task.status == 'passing' }
    end
  end

  def tasks_failing
    Rails.cache.fetch("#{cache_key}/tasks_failing") do
      tasks.select { |task| task.status == 'failing' }
    end
  end

  def tasks_incomplete
    Rails.cache.fetch("#{cache_key}/tasks_incomplete") do
      tasks.select { |task| task.status == 'incomplete' }
    end
  end
end
