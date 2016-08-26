# rubocop:disable Metrics/ClassLength
class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include GlobalID::Identification
  include HealthDataStandards::CQM

  default_scope -> { order(:updated_at => :desc) }

  # TODO: Use real attributes?
  scope :measure_tests, -> { where(_type: 'MeasureTest') }
  scope :checklist_tests, -> { where(_type: 'ChecklistTest') }
  scope :filtering_tests, -> { where(_type: 'FilteringTest') }

  belongs_to :product, index: true, touch: true
  has_many :tasks, :dependent => :destroy

  has_many :records, :dependent => :destroy, :foreign_key => :test_id

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
  mount_uploader :html_archive, PatientArchiveUploader

  delegate :effective_date, :to => :product
  delegate :bundle, :to => :product

  def self.inherited(child)
    child.instance_eval do
      def model_name
        ProductTest.model_name
      end
    end
    super
  end

  # This is a helper method for the vendor and product cleanup code. It takes a collection of
  # product test ID's and deletes those ProducTests along with all associated data.
  def self.destroy_by_ids(product_test_ids)
    tasks = Task.where(:product_test_id.in => product_test_ids)
    task_ids = tasks.pluck(:_id)
    records = Record.where(:test_id.in => product_test_ids)
    record_ids = records.pluck(:_id)
    test_executions = TestExecution.where(:task_id.in => task_ids)
    test_execution_ids = test_executions.pluck(:_id)

    records.delete
    tasks.delete
    test_executions.delete

    # Artifact runs a destroy instead of a delete in order to invoke the file callbacks from
    # carrierwave. Without this the system would be left with a lot of uploaded files on it
    # long after the parent data was destroyed.
    Artifact.where(:test_execution_id.in => test_execution_ids).destroy
    HealthDataStandards::CQM::PatientCache.where(:'value.patient_id'.in => record_ids).delete
    ProductTest.in(id: product_test_ids).delete
  end

  def generate_records
    ids = PatientCache.where('value.measure_id' => { '$in' => measure_ids }, 'value.IPP' => { '$gt' => 0 }).collect do |pcv|
      pcv.value['medical_record_id']
    end
    # selects between half and all of the unique ids
    ids = ids.uniq.sample(rand((ids.count / 2.0).ceil..(ids.count)))
    if product.randomize_records
      random_ids = bundle.records.where(test_id: nil).pluck('medical_record_number').uniq
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => ids, 'randomization_ids' => random_ids,
                                      'randomize_demographics' => true, 'generate_provider' => product.c4_test).perform
    else
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => ids, 'disable_randomization' => true).perform
    end
  end

  def archive_records
    file = Tempfile.new("product_test-#{id}.zip")
    Cypress::PatientZipper.zip(file, records, :qrda)
    self.patient_archive = file

    file = Tempfile.new("product_test-html-#{id}.zip")
    Cypress::PatientZipper.zip(file, records, :html)
    self.html_archive = file
    save
  end

  def calculate
    MeasureEvaluationJob.perform_later(self, {})
  end

  def measures
    bundle.measures.in(hqmf_id: measure_ids)
  end

  def execute(_params)
    raise NotImplementedError
  end

  def results
    PatientCache.where('value.test_id' => id).order_by(['value.last', :asc])
  end

  def ready
    self.state = :ready
    save
  end

  def queued
    self.state = :queued
    save
  end

  def building
    self.state = :building
    save
  end

  def errored
    self.state = :errored
    save
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      if tasks_by_status('failing').count > 0
        'failing'
      elsif tasks_by_status('passing').count == tasks.count && tasks.count > 0
        'passing'
      elsif tasks_by_status('errored').count > 0
        'errored'
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
    Time.at(bundle.measure_period_start).in_time_zone
  end

  def end_date
    Time.at(effective_date).in_time_zone
  end
end
