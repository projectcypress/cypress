class Product
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :vendor, index: true, touch: true
  has_and_belongs_to_many :users, index: true
  has_many :product_tests, dependent: :destroy


  field :name, type: String
  field :version, type: String
  field :description, type: String

  validates_presence_of :name

 # a product is only passing if all of it's tests have passed
  def passing?
    return true if self.product_tests.empty?

    passing = self.product_tests.includes(:test_executions).select do |p|
      p.execution_state == :passed
    end
    passing.length == product_tests.length
  end

  #failing if at least one of the tests is failing
  def failing?
    return false if self.product_tests.empty?
    failing = self.product_tests.includes(:test_executions).select do |p|
       p.execution_state == :failed
    end
    failing.length > 0
  end


  # Get the tests owned by this product that are failing
  def failing_tests
    return self.product_tests.includes(:test_executions).select do |test|
       test.execution_state == :failed
    end
  end

  # Get the tests owned by this product that are incomplete
  def incomplete_tests
    return self.product_tests.includes(:test_executions).select do |test|
      test.execution_state == :pending
    end
  end

  # Get the tests owned by this product that are passing
  def passing_tests
    return self.product_tests.includes(:test_executions).select do |test|
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
