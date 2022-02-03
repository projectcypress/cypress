# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include GlobalID::Identification

  scope :by_updated_at, -> { order(updated_at: :desc) }

  # TODO: Use real attributes?
  scope :measure_tests, -> { where(_type: 'MeasureTest') }
  scope :checklist_tests, -> { where(_type: 'ChecklistTest') }
  scope :filtering_tests, -> { where(_type: 'FilteringTest') }
  scope :multi_measure_tests, -> { where(_type: 'MultiMeasureTest') }
  scope :cms_program_tests, -> { where(_type: 'CMSProgramTest') }

  belongs_to :product, index: true, touch: true
  has_many :tasks, dependent: :destroy, inverse_of: :product_test

  # TODO: R2P: fix foreign key descriptor?
  has_many :patients, dependent: :destroy, foreign_key: 'correlation_id', class_name: 'CQM::ProductTestPatient'

  field :augmented_patients, type: Array, default: []

  field :expected_results, type: Hash
  # this the hqmf id of the measure
  field :measure_ids, type: Array
  # Test Details
  field :name, type: String
  field :cms_id, type: String
  field :description, type: String
  field :state, type: Symbol, default: :pending
  field :rand_seed, type: String

  field :backtrace, type: String
  field :status_message, type: String
  validates :name, presence: true
  validates :product, presence: true
  validates :measure_ids, presence: true
  mount_uploader :patient_archive, PatientArchiveUploader
  mount_uploader :html_archive, PatientArchiveUploader

  delegate :cures_update, to: :product
  delegate :name, :version, to: :product, prefix: true
  delegate :effective_date, to: :product
  delegate :measure_period_start, to: :product
  delegate :bundle, to: :product
  delegate :slim_test_deck?, to: :product
  delegate :test_deck_max, to: :product
  delegate :c1_test, :c2_test, :c3_test, to: :product

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
    patients = ProductTestPatient.where(:correlation_id.in => product_test_ids)
    patient_ids = patients.pluck(:_id)
    test_executions = TestExecution.where(:task_id.in => task_ids)
    test_execution_ids = test_executions.pluck(:_id)

    patients.delete
    tasks.delete
    test_executions.delete

    # Artifact runs a destroy instead of a delete in order to invoke the file callbacks from
    # carrierwave. Without this the system would be left with a lot of uploaded files on it
    # long after the parent data was destroyed.
    Artifact.where(:test_execution_id.in => test_execution_ids).destroy
    CQM::IndividualResult.where(:patient_id.in => patient_ids).delete
    ProductTest.in(id: product_test_ids).delete
  end

  def generate_patients(job_id = nil)
    if product.randomize_patients
      # If we're using a "slim test deck", don't pass in any random IDs
      random_ids = slim_test_deck? ? [] : gather_patient_ids
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => master_patient_ids, 'randomization_ids' => random_ids,
                                      'randomize_demographics' => true, 'generate_provider' => product.c4_test, 'job_id' => job_id).perform
    else
      Cypress::PopulationCloneJob.new('test_id' => id, 'patient_ids' => master_patient_ids, 'disable_randomization' => true).perform
    end
  end

  def archive_patients
    file = Tempfile.new("product_test-#{id}.zip")
    pat_arr = patients.to_a
    if product.duplicate_patients && _type != 'FilteringTest'
      prng = Random.new(rand_seed.to_i)
      # ids of all patients in IPP
      ids = results.where('IPP' => { '$gt' => 0 }).collect(&:patient_id)
      pat_arr = sample_and_duplicate_patients(pat_arr, ids, random: prng) if ids.present?
    end
    Cypress::PatientZipper.zip(file, pat_arr, :qrda)
    patient_archive.store!(file)

    file = Tempfile.new("product_test-html-#{id}.zip")
    Cypress::PatientZipper.zip(file, pat_arr, :html)
    html_archive.store!(file)
    save
  end

  def sample_and_duplicate_patients(pat_arr, ids, random: Random.new)
    car = ::Validators::CalculatingAugmentedRecords.new(measures, [], id)
    dups = patients.find(ids)

    # Don't randomize clinical_data for hybrid measures
    pat_arr, dups = randomize_clinical_data(pat_arr, dups, random) unless hybrid_measures?
    # choose up to 3 duplicate patients
    dups.sample(random.rand(1..3), random: random).each do |pat|
      prng_repeat = Random.new(rand_seed.to_i)
      dup_pat, pat_augments, old_pat = pat.duplicate_randomization(augmented_patients, random: prng_repeat)
      # only add if augmented patient validates
      if car.validate_calculated_results(dup_pat, effective_date: effective_date, orig_product_patient: old_pat)
        augmented_patients << pat_augments
        pat_arr << dup_pat
      else
        augmented_patients << { original_patient_id: old_pat.id,
                                first: [old_pat.first_names, old_pat.first_names], last: [old_pat.familyName, old_pat.familyName] }
        pat_arr << old_pat
      end
    end
    pat_arr
  end

  def randomize_clinical_data(pat_arr, dups, random)
    # Pick a patient to clinically randomize, then delete it from dups (so it doesn't get duplicated also)
    # And delete it from pat_arr so we don't return the whole patient too
    # TODO: check... why not randomize if there is one duplicate?
    return [pat_arr, dups] if dups.count < 1

    clinical_pat = dups.sample(random: random)
    dups.delete(clinical_pat)
    pat_arr.delete(clinical_pat)
    # Re-add clinically randomized patients (patient split in two across date or data element type)
    # use end and start dates for correct comparison format
    [pat_arr.concat(Cypress::ClinicalRandomizer.randomize(clinical_pat, end_date, start_date, random: random)), dups]
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
    CQM::IndividualResult.where(correlation_id: id.to_s)
  end

  %i[ready queued building errored].each do |test_state|
    define_method test_state do
      self.state = test_state
      save
    end
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      grouped_tasks = tasks.group_by(&:status)
      if grouped_tasks.key?('failing') && grouped_tasks['failing'].count.positive?
        'failing'
      elsif grouped_tasks.key?('passing') && grouped_tasks['passing'].count == tasks.size
        'passing'
      elsif grouped_tasks.key?('errored') && grouped_tasks['errored'].count.positive?
        'errored'
      else
        'incomplete'
      end
    end
  end

  # The name to display on a button to view this test (e.g., Previous/Next Test)
  def button_short_name
    cms_id.nil? ? name : cms_id
  end

  def start_date
    Time.at(measure_period_start).in_time_zone
  end

  def end_date
    Time.at(effective_date).in_time_zone
  end

  def update_with_checklist_tests(checklist_test_params)
    update(checklist_test_params)
    # reverse_each as criteria may be deleted as iterating
    checked_criteria.reverse_each(&:change_criteria)
    checked_criteria.each(&:validate_criteria)

    save!
  end

  def self.most_recent
    by_updated_at.first
  end

  def most_recent_task_execution_incomplete?
    tasks.any? && tasks[0].most_recent_execution && tasks[0].most_recent_execution.incomplete?
  end

  def most_recent_task_execution
    tasks[0].most_recent_execution
  end

  # Are any of the measures in this test a Hybrid measure
  def hybrid_measures?
    !(measures.map(&:hqmf_set_id) & APP_CONSTANTS['result_measures'].map(&:hqmf_set_id)).empty?
  end

  # Are any of the measures in this test EH
  def eh_measures?
    measures.pluck(:reporting_program_type).include?('eh')
  end

  # Are any of the measures in this test EH
  def ep_measures?
    measures.pluck(:reporting_program_type).include?('ep')
  end

  # A measure test has a C1 Task if the product has C1 criteria, or C3 criteria with EH measures
  def c1_task?
    product.c1_test || (product.c3_test && eh_measures?)
  end

  # A measure test has a C2 Task if the product has C2 criteria, or C3 criteria with EP measures
  def c2_task?
    product.c2_test || (product.c3_test && ep_measures?)
  end

  # A measure test has a C3 Cat I Task if the product has C3 and EH measures
  def c3_cat1_task?
    product.c3_test && eh_measures?
  end

  # A measure test has a C3 Cat III Task if the product has C3 and EP measures
  def c3_cat3_task?
    product.c3_test && ep_measures?
  end

  private

  def gather_patient_ids
    aggregate_id_list = []
    # if it's a cvu_plus product
    if product.cvuplus
      # then check if vendor and/or patients are included in product
      if product.vendor_patients
        # If so, add appropriate vendor patient ids
        aggregate_id_list.concat product.vendor_patient_ids
      end
      if product.bundle_patients
        # If so, add appropriate bundle patient ids
        aggregate_id_list.concat bundle.patients.pluck(:id)
      end
      # Check for neither as an edge case
      if aggregate_id_list == []
        # In theory, this should never happen.
        Rails.logger.error 'User was able to select an option for which there were no template patients.'
      end
    # For cert products (the only option to cvu, hence the else) just grab bundle patients
    else
      aggregate_id_list.concat bundle.patients.pluck(:id)
    end
    aggregate_id_list
  end

  # Returns a listing of all ids for patients in the IPP
  def patients_in_ipp_and_greater
    Patient.find(gather_patient_ids).keep_if do |p|
      p.patient_relevant?(measures.pluck(:_id), ['IPP'])
    end.pluck(:_id)
  end

  # Returns a listing of all ids for patients in the Numerator
  def patient_in_numerator
    Patient.find(gather_patient_ids).keep_if do |p|
      p.patient_relevant?(measures.pluck(:_id), ['NUMER'])
    end.pluck(:_id)
  end

  # Returns a listing of all ids for patients in the Denominator
  def patients_in_denominator_and_greater
    Patient.find(gather_patient_ids).keep_if do |p|
      p.patient_relevant?(measures.pluck(:_id), ['DENOM'])
    end.pluck(:_id)
  end

  # Returns a listing of all ids for patients in the Measure Population
  def patients_in_measure_population_and_greater
    Patient.find(gather_patient_ids).keep_if do |p|
      p.patient_relevant?(measures.pluck(:_id), ['MSRPOPL'])
    end.pluck(:_id)
  end

  # Returns a listing of all ids for patients in the Measure Population
  def patients_in_high_value_populations
    Patient.find(gather_patient_ids).keep_if do |p|
      p.patient_relevant?(measures.pluck(:_id), %w[NUMER NUMEX DENEXCEP DENEX])
    end.pluck(:_id)
  end

  def master_patient_ids
    mpl_ids = patients_in_ipp_and_greater
    return randomize_master_patient_ids(mpl_ids) if product.randomize_patients

    mpl_ids.compact
  end

  def randomize_master_patient_ids(mpl_ids)
    denom_ids = pick_denom_ids

    msrpopl_ids = pick_msrpopl_ids

    ipp_ids = (mpl_ids - denom_ids - msrpopl_ids)

    # Pick 3 IDs from the IPP.
    (ipp_ids.sample(3) + denom_ids + msrpopl_ids).compact
  end

  def pick_denom_ids
    # numer_id ensures we get at least one patient who is in the Numerator, no matter what
    numer_id = patient_in_numerator.sample
    denom_ids = patients_in_denominator_and_greater

    # If there are a lot of patients in denom_ids (usually when the IPP and denominator are the same thing),
    # pull out the numerator/Denex/Denexcep patients as high value (this is numer_ids), then sample from the rest to get to TEST_DECK_MAX
    # NOTE: "a lot" is defined by the relation to "TEST_DECK_MAX" on the product,
    if denom_ids.count > (test_deck_max - 1)
      high_value_ids = patients_in_high_value_populations
      high_value_ids = high_value_ids.sample(test_deck_max - 1)
      denom_ids = high_value_ids + denom_ids.sample(3)
    end
    patients_in_denominator_and_greater.empty? ? [numer_id] : (denom_ids << numer_id).uniq
  end

  def pick_msrpopl_ids
    msrpopl_ids = patients_in_measure_population_and_greater

    # If there are a lot of patients in the MSRPOPL results above, (usually if there are a lot of MSRPOPLEX values)
    # pull out only those patients with more than one episode in the MSRPOPL
    if msrpopl_ids.count > test_deck_max
      numer_ids = BundlePatient.where("measure_relevance_hash.#{measures.pluck(:_id).first}.MSRPOPL": true).pluck(:_id)
      numer_ids = numer_ids.sample(test_deck_max)
      msrpopl_ids = numer_ids + msrpopl_ids.sample(test_deck_max - numer_ids.count)
    end
    msrpopl_ids
  end

  def generate_random_seed
    # create and store a new random seed for debugging repeatability
    self.rand_seed = Random.new_seed.to_s unless rand_seed
  end
end
# rubocop:enable Metrics/ClassLength
