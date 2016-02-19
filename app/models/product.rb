class Product
  include Mongoid::Document
  include Mongoid::Attributes::Dynamic
  include Mongoid::Timestamps

  belongs_to :vendor, index: true, touch: true
  has_many :product_tests, :dependent => :destroy
  accepts_nested_attributes_for :product_tests, allow_destroy: true
  # NOTE: more relationships must be defined

  field :name, type: String
  field :version, type: String
  field :description, type: String
  # field :ehr_type, type: String
  field :c1_test, type: Boolean
  field :c2_test, type: Boolean
  field :c3_test, type: Boolean
  field :c4_test, type: Boolean
  field :randomize_records, type: Boolean
  # field :measure_selection, type: String

  validates :name, presence: true,
                   uniqueness: { :scope => :vendor,
                                 :message => 'Product name was already taken. Please choose another.' }
  # validates :ehr_type, presence: true, inclusion: { in: %w(provider hospital) }
  validate :meets_required_certification_types?
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

  def at_least_one_measure?
    errors.add(:measure_tests, 'Product must specify least one measure for testing.') unless product_tests.any?
  end

  def measure_ids
    (product_tests.pluck(:measure_ids) || []).flatten.uniq
  end

  def add_product_tests_to_product(added_measure_ids = [])
    return if added_measure_ids.nil?

    new_ids = added_measure_ids - measure_ids
    to_remove_ids = measure_ids - added_measure_ids
    untouched_ids = measure_ids - to_remove_ids
    if c1_test || c2_test || c3_test
      new_ids.each do |new_measure_id|
        measure = Measure.top_level.find_by(hqmf_id: new_measure_id)
        product_tests.build({ name: measure.name, product: self, measure_ids: [new_measure_id],
                              cms_id: measure.cms_id, bundle_id: measure.bundle_id }, MeasureTest)
      end
    end

    to_remove_ids.each { |old_measure_id| product_tests.in(measure_ids: old_measure_id).destroy }

    add_filtering_tests(ApplicationController.helpers.pick_measure_for_filtering_test(untouched_ids + new_ids)) if c4_test
  end

  def add_filtering_tests(measure)
    save!
    reload_relations

    if product_tests.where(_type: FilteringTest).count == 0
      criteria = %w(races ethnicities genders payers).shuffle
      filter_tests = []
      filter_tests << build_filtering_test(measure, criteria[0, 2])
      filter_tests << build_filtering_test(measure, criteria[2, 2])
      filter_tests << build_filtering_test(measure, ['providers'], 'Providers 1')
      filter_tests << build_filtering_test(measure, ['providers'], 'Providers 2', false)
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
                           bundle_id: measure.bundle_id, incl_addr: incl_addr, display_name: display_name, options: options }, FilteringTest)
  end
end
