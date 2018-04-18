# rubocop:disable ClassLength

class Product
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  before_save :enforce_cert_edition_settings

  mount_uploader :supplemental_test_artifact, SupplementUploader

  scope :by_updated_at, -> { order(:updated_at => :desc) }
  scope :ordered_for_vendors, -> { by_updated_at.order_by(:state => 'desc') }

  belongs_to :vendor, :index => true, :touch => true
  has_many :product_tests, :dependent => :destroy
  accepts_nested_attributes_for :product_tests, :allow_destroy => true
  belongs_to :bundle, :index => true
  # NOTE: more relationships must be defined

  field :name, :type => String
  field :version, :type => String
  field :description, :type => String
  field :cert_edition, :type => String, :default => '2015'
  %i[c1_test c2_test c3_test c4_test].each do |test|
    field test, :type => Boolean, :default => false
  end
  field :randomize_patients, :type => Boolean, :default => true
  field :duplicate_patients, :type => Boolean
  field :shift_patients, :type => Boolean, :default => false
  field :allow_duplicate_names, :type => Boolean, :default => false
  field :measure_selection, :type => String
  field :measure_ids, :type => Array
  field :favorite_user_ids, :type => Array, :default => []

  delegate :effective_date, :to => :bundle

  validates :name, :presence => true, :uniqueness => { :scope => :vendor, :message => 'Product name was already taken. Please choose another.' }

  validate :meets_required_certification_types?
  validate :valid_measure_ids?
  validates :vendor, :presence => true

  delegate :name, :to => :vendor, :prefix => true

  def measure_period_start
    # If selected, move measure period start date forward to the beginning of the actual reporting period
    shift_patients ? (bundle.measure_period_start + bundle.start_date_offset) : bundle.measure_period_start
  end

  def effective_date
    # If selected, move effective date forward to the end of the actual reporting period
    shift_patients ? (Time.at(measure_period_start).in_time_zone + 1.year - 1.second).to_i : bundle.effective_date
  end

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      grouped_products = product_tests.includes(:tasks).group_by(&:status)
      total = product_tests.size
      if grouped_products.key?('failing') && grouped_products['failing'].count.positive?
        'failing'
      elsif grouped_products.key?('passing') && grouped_products['passing'].count == total
        c1_test && product_tests.checklist_tests.empty? ? 'incomplete' : 'passing'
      elsif grouped_products.key?('errored') && grouped_products['errored'].count.positive?
        'errored'
      else
        'incomplete'
      end
    end
  end

  def meets_required_certification_types?
    errors.add(:tests, 'Product must certify to at least C1, C2, C3, or C4.') unless c1_test || c2_test || c3_test || c4_test
  end

  def valid_measure_ids?
    if measure_ids.blank?
      errors.add(:measure_ids, 'must select at least one')
    else
      mids = measure_ids.uniq
      errors.add(:measure_ids, 'must be valid hqmf ids') unless bundle.measures.top_level.where(:hqmf_id => { '$in' => mids }).length >= mids.count
    end
  end

  # updates product attributes and adds / removes measure tests
  # replaces checklist tests if any c1 checklist measures are removed
  # replaces all filtering tests and creates new filtering tests
  def update_with_measure_tests(product_params)
    add_measure_tests(product_params)
    save!
    add_filtering_tests if c4_test
    add_checklist_test if c1_test
  end

  def add_measure_tests(product_params)
    old_ids = measure_ids ? measure_ids : []
    new_ids = product_params['measure_ids'] ? product_params['measure_ids'] : old_ids
    update_attributes(product_params)
    (new_ids - old_ids).each do |measure_id|
      m = bundle.measures.top_level.find_by(:hqmf_id => measure_id)
      product_tests.build({ :name => m.name, :measure_ids => [measure_id], :cms_id => m.cms_id }, MeasureTest)
    end
    # remove measure and checklist tests if their measure ids have been removed
    product_tests.in(:measure_ids => (old_ids - new_ids)).destroy
  end

  # builds a checklist test if product does not have a checklist test
  def add_checklist_test
    if product_tests.checklist_tests.empty? && c1_test
      checklist_test = product_tests.create!({ :name => 'c1 visual', :measure_ids => measure_ids }, ChecklistTest)
      checklist_test.create_checked_criteria
      checklist_test.tasks.create!({}, C1ChecklistTask)
      checklist_test.tasks.create!({}, C3ChecklistTask) if c3_test
    end
  end

  def self.most_recent
    by_updated_at.first
  end

  # This method does nothing more than attempt to cleanup a lot of data instead of making rails do it,
  # since rails is really bad at cleaning up quickly.
  def destroy
    ProductTest.destroy_by_ids(product_test_ids)

    super
  end

  def slim_test_deck?
    cert_edition == '2014' || !c2_test
  end

  def test_deck_max
    return 5 if slim_test_deck?
    50
  end

  # - - - - - - - - - #
  #   P R I V A T E   #
  # - - - - - - - - - #

  def add_filtering_tests
    measure = ApplicationController.helpers.pick_measure_for_filtering_test(measure_ids, bundle)
    reload_relations

    return if product_tests.filtering_tests.any?
    #TODO R2P: check new criteria names
    criteria = %w[races ethnicities genders payers age].shuffle
    filter_tests = []
    filter_tests.concat [build_filtering_test(measure, criteria[0, 2]), build_filtering_test(measure, criteria[2, 2])]
    filter_tests << build_filtering_test(measure, ['providers'], 'NPI, TIN & Provider Location')
    filter_tests << build_filtering_test(measure, ['providers'], 'NPI & TIN', false)
    criteria = ApplicationController.helpers.measure_has_diagnosis_criteria?(measure) ? ['problems'] : criteria.values_at(4, (0..3).to_a.sample)
    filter_tests << build_filtering_test(measure, criteria)
    ApplicationController.helpers.generate_filter_patients(filter_tests)
  end

  # When the 2014 certification edition is enabled, duplicate_patients is always disabled.
  # Since the default for duplicate_patients is true, we override it here. We also make sure
  # that c4_test is not somehow set to true.
  def enforce_cert_edition_settings
    if cert_edition.eql? '2014'
      self.duplicate_patients = false
      self.c4_test = false
    elsif (cert_edition.eql? '2015') && duplicate_patients.nil?
      self.duplicate_patients = c2_test
    end

    true
  end

  def build_filtering_test(measure, criteria, display_name = '', incl_addr = true)
    # construct options hash from criteria array and create the test
    options = { 'filters' => Hash[criteria.map { |c| [c, []] }] }
    product_tests.create({ :name => measure.name, :product => self, :measure_ids => [measure.hqmf_id], :cms_id => measure.cms_id,
                           :incl_addr => incl_addr, :display_name => display_name, :options => options }, FilteringTest)
  end
end
