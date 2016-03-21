class Product
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

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
  field :randomize_records, type: Boolean
  field :duplicate_records, type: Boolean, default: true
  field :measure_selection, type: String
  field :measure_ids, type: Array

  delegate :effective_date, :to => :bundle

  validates :name, presence: true, uniqueness: { :scope => :vendor, :message => 'Product name was already taken. Please choose another.' }

  validate :meets_required_certification_types?
  validate :valid_measure_ids?
  validates :vendor, presence: true

  def status
    Rails.cache.fetch("#{cache_key}/status") do
      total = product_tests.count
      if product_tests_failing.count > 0
        'failing'
      elsif product_tests_passing.count == total && total > 0
        'passing'
      else
        'incomplete'
      end
    end
  end

  def product_tests_passing
    Rails.cache.fetch("#{cache_key}/product_tests_passing") do
      product_tests.select { |product_test| product_test.status == 'passing' }
    end
  end

  def product_tests_failing
    Rails.cache.fetch("#{cache_key}/product_tests_failing") do
      product_tests.select { |product_test| product_test.status == 'failing' }
    end
  end

  def product_tests_incomplete
    Rails.cache.fetch("#{cache_key}/product_tests_incomplete") do
      product_tests.select { |product_test| product_test.status == 'incomplete' }
    end
  end

  def meets_required_certification_types?
    errors.add(:tests, 'Product must certify to at least C1 or C2.') unless c1_test || c2_test
  end

  def valid_measure_ids?
    # byebug if measure_ids == [] || measure_ids == nil
    if measure_ids.nil? || measure_ids.empty?
      errors.add(:measure_ids, 'must select at least one')
    else
      measure_ids.each do |measure_id|
        errors.add(:measure_ids, 'must be valid hqmf ids') unless Measure.top_level.where(hqmf_id: measure_id).any?
      end
    end
  end

  def at_least_one_measure?
    errors.add(:measure_tests, 'Product must specify least one measure for testing.') unless product_tests.any?
  end

  # updates product attributes and adds / removes measure tests
  # replaces all filtering tests and creates new filtering tests
  def update_with_measure_tests(product_params)
    new_ids = product_params['measure_ids'] ? product_params['measure_ids'] : []
    old_ids = measure_ids ? measure_ids : []
    update_attributes(product_params)
    (new_ids - old_ids).each do |measure_id|
      m = bundle.measures.top_level.find_by(hqmf_id: measure_id)
      product_tests.build({ name: m.name, measure_ids: [measure_id], cms_id: m.cms_id }, MeasureTest)
    end
    (old_ids - new_ids).each { |measure_id| product_tests.in(measure_ids: measure_id).destroy }
    add_filtering_tests if c4_test
  end

  def add_filtering_tests
    measure = ApplicationController.helpers.pick_measure_for_filtering_test(measure_ids, bundle)
    save!
    reload_relations

    if product_tests.filtering_tests.count == 0
      criteria = %w(races ethnicities genders payers).shuffle
      filter_tests = []
      filter_tests << build_filtering_test(measure, criteria[0, 2])
      filter_tests << build_filtering_test(measure, criteria[2, 2])
      filter_tests << build_filtering_test(measure, ['providers'], 'NPI, TIN & Provider Location')
      filter_tests << build_filtering_test(measure, ['providers'], 'NPI & TIN', false)
      filter_tests << if ApplicationController.helpers.measure_has_diagnosis_criteria?(measure)
                        build_filtering_test(measure, ['problems'])
                      else
                        # the measure doesn't have a diagnosis so instead create a new demographics task
                        # we used the combos [0,1] and [2,3] previously
                        # so to make a unique third test here use any combo that has 0 or 1 first and 2 or 3 second
                        build_filtering_test(measure, criteria.values_at([0, 1].sample, [2, 3].sample))
                      end
      ApplicationController.helpers.generate_filter_records(filter_tests)
    end
  end

  def build_filtering_test(measure, criteria, display_name = '', incl_addr = true)
    # construct options hash from criteria array and create the test
    options = { 'filters' => Hash[criteria.map { |c| [c, []] }] }
    product_tests.create({ name: measure.name, product: self, measure_ids: [measure.hqmf_id], cms_id: measure.cms_id,
                           incl_addr: incl_addr, display_name: display_name, options: options }, FilteringTest)
  end
end
