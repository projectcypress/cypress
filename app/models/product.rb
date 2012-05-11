class Product
  include Mongoid::Document

  belongs_to :vendor
  has_and_belongs_to_many :users
  has_many :product_tests, dependent: :destroy

  
  field :name, type: String
  field :version, type: String
  field :description, type: String
  field :measure_map, type: Hash
  validates_presence_of :name
  # If all of the ProductTests passed, then this Product will be considered passing
  def passing?
    return (self.product_tests.size > 0) && (self.product_tests.size == self.count_passing)
  end
  
  # Get the tests owned by this product that are failing
  def failing_tests
    return self.product_tests.select do |test|
      !test.passing?
    end
  end

  # Get the tests owned by this product that are incomplete
  def incomplete_tests
    return self.product_tests.select do |test|
      test.reported_results.nil?
    end
  end
  
  # Get the tests owned by this product that are passing
  def passing_tests
    return self.product_tests.select do |test|
      test.passing?
    end
  end
  
  # Count the number of associated ProductTests that are passing
  def count_passing
    return self.passing_tests.size
  end
  
  # The percentage of passing tests. Returns 0 if no products
  def success_rate
    return 0 if self.product_tests.empty?
    return self.count_passing.to_f / self.product_tests.size
  end

  # provide a default measure_map if none exist for the given product
  def measure_map
    return self[:measure_map] if self[:measure_map]

    measure_map = {}
    Measure.installed.each { |m| measure_map[m.key] = m.key }
    return measure_map

  end
end
