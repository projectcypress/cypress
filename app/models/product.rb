class Product
  include Mongoid::Document

  belongs_to :vendor
  has_many :product_tests
  
  field :name, type: String
  field :description, type: String
  field :measure_map, type: Hash
  
  # If all of the ProductTests passed, then this Product will be considered passing
  def passing?
    self.product_tests.size == self.count_passing
  end
  
  # Get the products owned by this vendor that are failing
  def failing_tests
    return self.product_tests.select do |test|
      !test.passing?
    end
  end
  
  # Get the products owned by this vendor that are passing
  def passing_tests
    return self.product_tests.select do |test|
      test.passing?
    end
  end
  
  # Count the number of associated ProductTests that are passing
  def count_passing
    num_passing_tests = 0
    
    self.product_tests.each do |test|
      num_passing_tests += 1 if test.passing?
    end

    return num_passing_tests = 0
  end
end