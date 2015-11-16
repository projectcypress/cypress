class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include HealthDataStandards::CQM

  belongs_to :product, index: true, touch: true
  has_many :tasks, :dependent => :destroy

  belongs_to :bundle, index: true

  field :expected_results, type: Hash
  # this the hqmf id of the measure
  field :measure_ids, type: Array
  # Test Details
  field :name, type: String
  field :cms_id, type: String
  field :description, type: String
  field :state, type: Symbol

  field :status_message, type: String
  # field :effective_date, type: Integer
  validates :name, presence: true
  validates :product, presence: true
  validates :measure_ids, presence: true
  # validates :effective_date, presence: true
  # validates :bundle_id, presence: true

  # delegate :effective_date, to: bundle

  after_create :generate_records

  def self.inherited(child)
    child.instance_eval do
      def model_name
        ProductTest.model_name
      end
    end
    super
  end

  def generate_records
    ids = PatientCache.where('value.measure_id' => { '$in' => measure_ids }, 'value.IPP' => { '$gt' => 0 }).collect do |pcv|
      pcv.value['medical_record_id']
    end
    ids.uniq!
    random_ids = Record.all.pluck('medical_record_number').uniq
    Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => ids, 'randomization_ids' =>  random_ids, 'randomize_names' => true).perform
    calculate
  end

  def calculate
    MeasureEvaluationJob.perform_later(self, {})
  end

  def measures
    bundle.measures.in(hqmf_id: measure_ids)
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

  delegate :effective_date, :to => :bundle

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

  def start_date
    Time.at(bundle.measure_period_start).utc
  end

  def end_date
    Time.at(effective_date).utc
  end
end
