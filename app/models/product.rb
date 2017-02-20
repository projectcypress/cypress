class Product
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  default_scope -> { order(:updated_at => :desc) }

  belongs_to :vendor, index: true, touch: true
  has_many :product_tests, :dependent => :destroy
  accepts_nested_attributes_for :product_tests, allow_destroy: true
  belongs_to :bundle, index: true
  # NOTE: more relationships must be defined

  field :name, type: String
  field :version, type: String
  field :description, type: String
  field :c1_test, type: Boolean
  field :c2_test, type: Boolean
  field :c3_test, type: Boolean
  field :c4_test, type: Boolean
  field :randomize_records, type: Boolean, default: true
  field :duplicate_records, type: Boolean, default: true
  field :allow_duplicate_names, type: Boolean, default: false
  field :measure_selection, type: String
  field :measure_ids, type: Array
  field :favorite_user_ids, type: Array, default: []

  delegate :effective_date, :to => :bundle

  validates :name, presence: true, uniqueness: { :scope => :vendor, :message => 'Product name was already taken. Please choose another.' }

  validate :meets_required_certification_types?
  validate :valid_measure_ids?
  validates :vendor, presence: true

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      grouped_products = product_tests.includes(:tasks).group_by(&:status)
      total = product_tests.size
      if grouped_products.key?('failing') && grouped_products['failing'].count > 0
        'failing'
      elsif grouped_products.key?('passing') && grouped_products['passing'].count == total
        c1_test && product_tests.checklist_tests.empty? ? 'incomplete' : 'passing'
      elsif grouped_products.key?('errored') && grouped_products['errored'].count > 0
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
    if measure_ids.nil? || measure_ids.empty?
      errors.add(:measure_ids, 'must select at least one')
    else
      mids = measure_ids.uniq
      errors.add(:measure_ids, 'must be valid hqmf ids') unless bundle.measures.top_level.where(hqmf_id: { '$in' => mids }).length >= mids.count
    end
  end

  def at_least_one_measure?
    errors.add(:measure_tests, 'Product must specify at least one measure for testing.') unless product_tests.any?
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
      m = bundle.measures.top_level.find_by(hqmf_id: measure_id)
      product_tests.build({ name: m.name, measure_ids: [measure_id], cms_id: m.cms_id }, MeasureTest)
    end
    # remove measure and checklist tests if their measure ids have been removed
    product_tests.in(measure_ids: (old_ids - new_ids)).destroy
  end

  # builds a checklist test if product does not have a checklist test
  def add_checklist_test
    if product_tests.checklist_tests.empty? && c1_test
      checklist_test = product_tests.create!({ name: 'c1 visual', measure_ids: measure_ids }, ChecklistTest)
      checklist_test.create_checked_criteria
      checklist_test.tasks.create!({}, C1ChecklistTask)
      checklist_test.tasks.create!({}, C3ChecklistTask) if c3_test
    end
  end

  # This method does nothing more than attempt to cleanup a lot of data instead of making rails do it,
  # since rails is really bad at cleaning up quickly.
  def destroy
    ProductTest.destroy_by_ids(product_test_ids)

    super
  end

  # - - - - - - - - - #
  #   P R I V A T E   #
  # - - - - - - - - - #

  def add_filtering_tests
    measure = ApplicationController.helpers.pick_measure_for_filtering_test(measure_ids, bundle)
    reload_relations

    return if product_tests.filtering_tests.any?
    criteria = %w(races ethnicities genders payers age).shuffle
    filter_tests = []
    filter_tests.concat [build_filtering_test(measure, criteria[0, 2]), build_filtering_test(measure, criteria[2, 2])]
    filter_tests << build_filtering_test(measure, ['providers'], 'NPI, TIN & Provider Location')
    filter_tests << build_filtering_test(measure, ['providers'], 'NPI & TIN', false)
    criteria = ApplicationController.helpers.measure_has_diagnosis_criteria?(measure) ? ['problems'] : criteria.values_at(4, (0..3).to_a.sample)
    filter_tests << build_filtering_test(measure, criteria)
    ApplicationController.helpers.generate_filter_records(filter_tests)
  end

  def build_filtering_test(measure, criteria, display_name = '', incl_addr = true)
    # construct options hash from criteria array and create the test
    options = { 'filters' => Hash[criteria.map { |c| [c, []] }] }
    product_tests.create({ name: measure.name, product: self, measure_ids: [measure.hqmf_id], cms_id: measure.cms_id,
                           incl_addr: incl_addr, display_name: display_name, options: options }, FilteringTest)
  end
end
