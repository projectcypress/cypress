# rubocop:disable Metrics/ClassLength
class ProductTest
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include GlobalID::Identification
  include HealthDataStandards::CQM

  scope :by_updated_at, -> { order(:updated_at => :desc) }

  # TODO: Use real attributes?
  scope :measure_tests, -> { where(:_type => 'MeasureTest') }
  scope :checklist_tests, -> { where(:_type => 'ChecklistTest') }
  scope :filtering_tests, -> { where(:_type => 'FilteringTest') }

  belongs_to :product, :index => true, :touch => true
  has_many :tasks, :dependent => :destroy

  has_many :patients, :dependent => :destroy, :foreign_key => :test_id

  field :augmented_patients, :type => Array, :default => []

  field :expected_results, :type => Hash
  # this the hqmf id of the measure
  field :measure_ids, :type => Array
  # Test Details
  field :name, :type => String
  field :cms_id, :type => String
  field :description, :type => String
  field :state, :type => Symbol, :default => :pending
  field :rand_seed, :type => String

  field :status_message, :type => String
  validates :name, :presence => true
  validates :product, :presence => true
  validates :measure_ids, :presence => true
  mount_uploader :patient_archive, PatientArchiveUploader
  mount_uploader :html_archive, PatientArchiveUploader

  delegate :name, :version, :to => :product, :prefix => true
  delegate :effective_date, :to => :product
  delegate :measure_period_start, :to => :product
  delegate :bundle, :to => :product
  delegate :c1_test, :c2_test, :c3_test, :to => :product

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
    patients = QDM::Patient.where(:test_id.in => product_test_ids)
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
    #TODO CQL: use new results model?
    HealthDataStandards::CQM::PatientCache.where(:'value.patient_id'.in => patient_ids).delete
    ProductTest.in(:id => product_test_ids).delete
  end

  def generate_patients(job_id = nil)
    if product.randomize_patients
      # If we're using a "slim test deck", don't pass in any random IDs
      random_ids = if product.slim_test_deck?
                     []
                   else
                     # TODO R2P: check correlationId name and ...where(:'extendedData.correlationId' => nil).pluck('extendedData.medical_record_number').uniq doesn't work
                     #get medical record numbers for master patients (have no correlation (test) id)
                     bundle.patients.where(:'extendedData.correlationId' => nil).map {|mp| mp[:extendedData][:medical_record_number] }.uniq
                   end
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
      ids = results.where('value.IPP' => { '$gt' => 0 }).collect { |pc| pc.value.patient_id }
      if ids.present?
        pat_arr = sample_and_duplicate_patients(pat_arr, ids, :random => prng)
      end
    end
    Cypress::PatientZipper.zip(file, pat_arr, :qrda)
    self.patient_archive = file

    file = Tempfile.new("product_test-html-#{id}.zip")
    Cypress::PatientZipper.zip(file, pat_arr, :html)
    self.html_archive = file
    save
  end

  def sample_and_duplicate_patients(pat_arr, ids, random: Random.new)
    car = ::Validators::CalculatingAugmentedRecords.new(measures, [], id)
    dups = patients.find(ids)

    pat_arr, dups = randomize_clinical_data(pat_arr, dups, random)
    #choose up to 3 duplicate patients
    dups.sample(random.rand(1..3), :random => random).each do |pat|
      prng_repeat = Random.new(rand_seed.to_i)
      dup_pat, pat_augments, old_pat = pat.duplicate_randomization(:random => prng_repeat)
      #only add if augmented patient validates
      if car.validate_calculated_results(dup_pat, 'effective_date' => effective_date)
        augmented_patients << pat_augments
        pat_arr << dup_pat
      else
        augmented_patients << { :medical_record_number => old_pat.extendedData.medical_record_number,
                               :first => [old_pat.first_names, old_pat.first_names], :last => [old_pat.familyName, old_pat.familyName] }
        pat_arr << old_pat
      end
    end
    pat_arr
  end

  def randomize_clinical_data(pat_arr, dups, random)
    #TODO R2P: change to use patient model
    # Pick a patient to clinically randomize, then delete it from dups (so it doesn't get duplicated also)
    # And delete it from pat_arr so we don't return the whole patient too
    return [pat_arr, dups] if dups.count < 2
    clinical_pat = dups.sample(:random => random)
    dups.delete(clinical_pat)
    pat_arr.delete(clinical_pat)
    # TODO R2P: change clinical randomizer to use data entries in new model
    # [pat_arr.concat(Cypress::ClinicalRandomizer.randomize(clinical_pat, effective_date, measure_period_start, :random => random)), dups]
  end

  def calculate
    MeasureEvaluationJob.perform_later(self, {})
  end

  def measures
    bundle.measures.in(:hqmf_id => measure_ids)
  end

  def execute(_params)
    raise NotImplementedError
  end

  def results
    # TODO CQL: use new results model
    PatientCache.where('value.test_id' => id).order_by(['value.last', :asc])
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

  def start_date
    Time.at(measure_period_start).in_time_zone
  end

  def end_date
    Time.at(effective_date).in_time_zone
  end

  def update_with_checklist_tests(checklist_test_params)
    update_attributes(checklist_test_params)
    checked_criteria.each(&:validate_criteria)
    checked_criteria.reverse_each(&:change_criteria)
    save!
  end

  def self.most_recent
    by_updated_at.first
  end

  private

  # Returns a listing of all ids for patients in the IPP
  def patients_in_ipp_and_greater
    IndividualResult.where('measure' => { '$in' => measures.pluck(:_id) },
                           'IPP' => { '$gt' => 0 }, 'extended_data.correlation_id' => bundle.id).distinct(:patient)
  end

  # Returns an id for a patient in the Numerator
  def patient_in_numerator
    IndividualResult.where('measure' => { '$in' => measures.pluck(:_id) },
                           'extended_data.correlation_id' => bundle.id, 'NUMER' => { '$gt' => 0 }).distinct(:patient).sample
  end

  # Returns a listing of all ids for patients in the Denominator
  def patients_in_denominator_and_greater
    IndividualResult.where('measure' => { '$in' => measures.pluck(:_id) },
                           'extended_data.correlation_id' => bundle.id, 'DENOM' => { '$gt' => 0 }).distinct(:patient)
  end

  # Returns a listing of all ids for patients in the Measure Population
  def patients_in_measure_population_and_greater
    IndividualResult.where('measure' => { '$in' => measures.pluck(:_id) },
                           'extended_data.correlation_id' => bundle.id, 'MSRPOPL' => { '$gt' => 0 }).distinct(:patient)
  end

  def master_patient_ids
    mpl_ids = patients_in_ipp_and_greater

    if product.randomize_records
      denom_ids = pick_denom_ids

      msrpopl_ids = pick_msrpopl_ids

      ipp_ids = (mpl_ids - denom_ids - msrpopl_ids)

      # Pick some IDs from the IPP. If we've already got a lot of patients, only pick a couple more, otherwise pick 1/2 or more
      ipp_ids = if (mpl_ids.count + denom_ids.count + msrpopl_ids.count) > product.test_deck_max
                  ipp_ids.sample(product.test_deck_max / 2)
                else
                  ipp_ids.sample(rand((ipp_ids.count / 2.0).ceil..(ipp_ids.count)))
                end
      return ipp_ids + denom_ids + msrpopl_ids
    end
    mpl_ids
  end

  def pick_denom_ids
    # numer_id ensures we get at least one patient who is in the Numerator, no matter what
    numer_id = patient_in_numerator
    denom_ids = patients_in_denominator_and_greater

    # If there are a lot of patients in denom_ids (usually when the IPP and denominator are the same thing),
    # pull out the numerator/Denex/Denexcep patients as high value (this is numer_ids), then sample from the rest to get to test_deck_max
    # NOTE: "a lot" is defined by the relation to "test_deck_max" on the product,
    # which is large (~50) for 2015 cert ed. & C2, small (~5) otherwise
    if denom_ids.count > (product.test_deck_max - 1)
      high_value_ids = IndividualResult.where('measure' => { '$in' => measures.pluck(:_id) }, 'extended_data.correlation_id' => bundle.id)
                                       .any_of({ 'NUMER' => { '$gt' => 0 } },
                                               { 'DENEXCEP' => { '$gt' => 0 } },
                                               'DENEX' => { '$gt' => 0 }).distinct(:patient)
      high_value_ids = high_value_ids.sample(product.test_deck_max - 1)
      denom_ids = high_value_ids + denom_ids.sample(product.test_deck_max - high_value_ids.count - 1)
    end
    (denom_ids << numer_id).uniq
  end

  def pick_msrpopl_ids
    msrpopl_ids = patients_in_measure_population_and_greater

    # If there are a lot of patients in the MSRPOPL results above, (usually if there are a lot of MSRPOPLEX values)
    # pull out only those patients with more than one episode in the MSRPOPL
    # and those patients with only 1 episode in the MSRPOPL but none in the MSRPOPLEX
    # NOTE: "a lot" is defined by the relation to "test_deck_max" on the product,
    # which is large (~50) for 2015 cert ed. & C2, small (~5) otherwise
    if msrpopl_ids.count > product.test_deck_max
      numer_ids = get_record_ids(
        IndividualResult.where('measure' => { '$in' => measures.pluck(:_id) }, 'extended_data.correlation_id' => bundle.id)
                        .any_of({ 'MSRPOPL' => { '$gt' => 1 } },
                                '$and' => [{ 'MSRPOPL' => { '$eq' => 1 } }, { 'MSRPOPLEX' => { '$eq' => 0 } }]).distinct(:patient)
      )
      numer_ids = numer_ids.sample(product.test_deck_max)
      msrpopl_ids = numer_ids + msrpopl_ids.sample(product.test_deck_max - numer_ids.count)
    end
    msrpopl_ids
  end

  def generate_random_seed
    # create and store a new random seed for debugging repeatability
    self.rand_seed = Random.new_seed.to_s unless rand_seed
  end
end
