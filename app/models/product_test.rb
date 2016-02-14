class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps
  include GlobalID::Identification
  include HealthDataStandards::CQM

  # TODO: Use real attributes?
  scope :measure_tests, -> { where(_type: 'MeasureTest') }
  scope :checklist_tests, -> { where(_type: 'ChecklistTest') }
  scope :filtering_tests, -> { where(_type: 'FilteringTest') }

  belongs_to :product, index: true, touch: true
  has_many :tasks, :dependent => :destroy

  has_many :records, :foreign_key => :test_id

  belongs_to :bundle, index: true

  field :expected_results, type: Hash
  # this the hqmf id of the measure
  field :measure_ids, type: Array
  # Test Details
  field :name, type: String
  field :cms_id, type: String
  field :description, type: String
  field :state, :type => Symbol, :default => :pending

  field :status_message, type: String
  validates :name, presence: true
  validates :product, presence: true
  validates :measure_ids, presence: true
  mount_uploader :patient_archive, PatientArchiveUploader

  delegate :effective_date, :to => :bundle

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

    if product.randomize_records
      random_ids = Record.where(test_id: nil).pluck('medical_record_number').uniq
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => ids, 'randomization_ids' => random_ids,
                                      'randomize_demographics' => true).perform
    else
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => ids, 'disable_randomization' => true).perform
    end
  end

  def archive_records
    file = Tempfile.new("product_test-#{id}.zip")
    Cypress::PatientZipper.zip(file, records, :qrda)
    self.patient_archive = file
    save
  end

  def calculate
    MeasureEvaluationJob.perform_later(self, {})
  end

  def contains_c3_task?
    tasks.count { |t| t.is_a? C3Task } > 0
  end

  def measures
    bundle.measures.in(hqmf_id: measure_ids)
  end

  def execute(_params)
    fail NotImplementedError
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
      if tasks_by_status('failing').count > 0
        'failing'
      elsif tasks_by_status('passing').count == total && total > 0
        'passing'
      else
        'incomplete'
      end
    end
  end

  def tasks_by_status(status)
    Rails.cache.fetch("#{cache_key}/tasks_#{status}") do
      tasks.select { |task| task.status == status }
    end
  end

  def start_date
    Time.at(bundle.measure_period_start).utc
  end

  def end_date
    Time.at(effective_date).utc
  end
end
