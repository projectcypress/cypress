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

  field :augmented_records, type: Array, default: []

  field :expected_results, type: Hash
  # this the hqmf id of the measure
  field :measure_ids, type: Array
  # Test Details
  field :name, type: String
  field :cms_id, type: String
  field :description, type: String
  field :state, :type => Symbol, :default => :pending
  field :rand_seed, type: String

  field :status_message, type: String
  validates :name, presence: true
  validates :product, presence: true
  validates :measure_ids, presence: true
  mount_uploader :patient_archive, PatientArchiveUploader
  mount_uploader :html_archive, PatientArchiveUploader

  delegate :effective_date, :to => :product
  delegate :bundle, :to => :product

  before_create :generate_random_seed

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

  def generate_records(job_id = nil)
    if product.randomize_records
      random_ids = bundle.records.where(test_id: nil).pluck('medical_record_number').uniq
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => master_patient_ids, 'randomization_ids' => random_ids,
                                      'randomize_demographics' => true, 'generate_provider' => product.c4_test, 'job_id' => job_id).perform
    else
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => master_patient_ids, 'disable_randomization' => true).perform
    end
  end

  def archive_records
    file = Tempfile.new("product_test-#{id}.zip")
    recs = records.to_a

    if product.duplicate_records
      prng = Random.new(rand_seed.to_i)
      ids = results.where('value.IPP' => { '$gt' => 0 }).collect { |pc| pc.value.patient_id }
      unless ids.nil? || ids.empty?
        recs = sample_and_duplicate_records(recs, ids, random: prng)
      end
    end
    Cypress::PatientZipper.zip(file, recs, :qrda)
    self.patient_archive = file

    file = Tempfile.new("product_test-html-#{id}.zip")
    Cypress::PatientZipper.zip(file, recs, :html)
    self.html_archive = file
    save
  end

  def sample_and_duplicate_records(recs, ids, random: Random.new)
    car = ::Validators::CalculatingAugmentedRecords.new(measures, [], id)
    dups = records.find(ids)

    recs, dups = randomize_clinical_data(recs, dups, random)
    dups.sample(random.rand(1..3), random: random).each do |rec|
      prng_repeat = Random.new(rand_seed.to_i)
      dup_rec, rec_augments, old_rec = rec.duplicate_randomization(random: prng_repeat)
      if car.validate_calculated_results(dup_rec, 'effective_date' => effective_date)
        augmented_records << rec_augments
        recs << dup_rec
      else
        augmented_records << { medical_record_number: old_rec.medical_record_number,
                               first: [old_rec.first, old_rec.first], last: [old_rec.last, old_rec.last] }
        recs << old_rec
      end
    end
    recs
  end

  def randomize_clinical_data(recs, dups, random)
    # Pic a record to clinically randomize, then delete it from dups (so it doesn't get duplicated also)
    # And delete it from recs so we don't return the whole patient too
    return [recs, dups] if dups.count < 2
    clinical_record = dups.sample(random: random)
    dups.delete(clinical_record)
    recs.delete(clinical_record)
    [recs.concat(Cypress::ClinicalRandomizer.randomize(clinical_record, random: random)), dups]
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

  [:ready, :queued, :building, :errored].each do |test_state|
    define_method test_state do
      self.state = test_state
      save
    end
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      grouped_tasks = tasks.group_by(&:status)
      if grouped_tasks.key?('failing') && grouped_tasks['failing'].count > 0
        'failing'
      elsif grouped_tasks.key?('passing') && grouped_tasks['passing'].count == tasks.size
        'passing'
      elsif grouped_tasks.key?('errored') && grouped_tasks['errored'].count > 0
        'errored'
      else
        'incomplete'
      end
    end
  end

  def start_date
    Time.at(bundle.measure_period_start).in_time_zone
  end

  def end_date
    Time.at(effective_date).in_time_zone
  end

  private

  def master_patient_ids
    mpl_ids = PatientCache.where('value.measure_id' => { '$in' => measure_ids },
                                 'value.test_id' => nil, 'value.IPP' => { '$gt' => 0 }).collect do |pcv|
      pcv.value['medical_record_id']
    end
    mpl_ids.uniq!
    mpl_ids.keep_if { |id| id[8] == '-' }
    if product.randomize_records
      denom_ids = pick_denom_ids

      msrpopl_ids = pick_msrpopl_ids

      ipp_ids = (mpl_ids - denom_ids - msrpopl_ids)

      # Pick some IDs from the IPP. If we've already got a lot of patients, only pick a couple more, otherwise pick 1/2 or more
      ipp_ids = if (mpl_ids.count + denom_ids.count + msrpopl_ids.count) > 50
                  ipp_ids.sample(10)
                else
                  ipp_ids.sample(rand((ipp_ids.count / 2.0).ceil..(ipp_ids.count)))
                end
      return ipp_ids + denom_ids + msrpopl_ids
    end
    mpl_ids
  end

  def pick_denom_ids
    denom_ids = PatientCache.where('value.measure_id' => { '$in' => measure_ids },
                                   'value.test_id' => nil, 'value.DENOM' => { '$gt' => 0 }).collect do |pcv|
      pcv.value['medical_record_id']
    end
    denom_ids.uniq!

    # If there are a lot of patients in denom_ids (usually when the IPP and denominator are the same thing),
    # pull out the numerator/Denex/Denexcep patients as high value, then sample from the rest to get to 60
    if denom_ids.count > 50
      numer_ids = PatientCache.where('value.measure_id' => { '$in' => measure_ids }, 'value.test_id' => nil)
                              .any_of({ 'value.NUMER' => { '$gt' => 0 } },
                                      { 'value.DENEXCEP' => { '$gt' => 0 } },
                                      'value.DENEX' => { '$gt' => 0 }).collect do |pcv|
        pcv.value['medical_record_id']
      end
      numer_ids.uniq!
      numer_ids.keep_if { |id| id[8] == '-' }
      numer_ids = numer_ids.sample(50)
      denom_ids = numer_ids + denom_ids.sample(50 - numer_ids.count)
    end
    denom_ids
  end

  def pick_msrpopl_ids
    msrpopl_ids = PatientCache.where('value.measure_id' => { '$in' => measure_ids },
                                     'value.test_id' => nil, 'value.MSRPOPL' => { '$gt' => 0 }).collect do |pcv|
      pcv.value['medical_record_id']
    end
    msrpopl_ids.uniq!

    # If there are a lot of patients in the MSRPOPL results above, (usually if there are a lot of MSRPOPLEX values)
    # pull out only those patients with more than one episode in the MSRPOPL
    # and those patients with only 1 episode in the MSRPOPL but none in the MSRPOPLEX
    if msrpopl_ids.count > 50
      numer_ids = PatientCache.where('value.measure_id' => { '$in' => measure_ids }, 'value.test_id' => nil)
                              .any_of({ 'value.MSRPOPL' => { '$gt' => 1 } },
                                      '$and' => [{ 'value.MSRPOPL' => { '$eq' => 1 } }, { 'value.MSRPOPLEX' => { '$eq' => 0 } }])
                              .collect do |pcv|
        pcv.value['medical_record_id']
      end
      numer_ids.uniq!
      numer_ids.keep_if { |id| id[8] == '-' }
      numer_ids = numer_ids.sample(50)
      msrpopl_ids = numer_ids + msrpopl_ids.sample(50 - numer_ids.count)
    end
    msrpopl_ids
  end

  def generate_random_seed
    # create and store a new random seed for debugging repeatability
    self.rand_seed = Random.new_seed.to_s unless rand_seed
  end
end
