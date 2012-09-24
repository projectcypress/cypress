class Product
  include Mongoid::Document

  belongs_to :vendor
  has_and_belongs_to_many :users
  has_many :product_tests, dependent: :destroy

  
  field :name, type: String
  field :version, type: String
  field :description, type: String

  validates_presence_of :name
 
 
  def passing?
    return false if self.product_tests.empty?
    
    pass=true
    self.product_tests.each do |p|
      pass = pass && p.execution_state == :passed
    end
    pass
  end

  # Get the tests owned by this product that are failing
  def failing_tests
    return self.product_tests.select do |test|
       test.execution_state == :failed
    end
  end

  # Get the tests owned by this product that are incomplete
  def incomplete_tests
    return self.product_tests.select do |test|
      test.execution_state == :pending
    end
  end
  
  # Get the tests owned by this product that are passing
  def passing_tests
    return self.product_tests.select do |test|
       test.execution_state == :passed
    end
  end
  
  # Count the number of associated ProductTests that are passing
  def count_passing
    return self.passing_tests.size
  end
  
  # Count the number of associated ProductTests that are failing
  def count_failing
    return self.failing_tests.size
  end

  # Count the number of associated ProductTests that are incomplete
  def count_incomplete
    return self.incomplete_tests.size
  end

  # The percentage of passing tests. Returns 0 if no products
  def success_rate
    return 0 if self.product_tests.empty?
    return self.count_passing.to_f / self.product_tests.size
  end

end
