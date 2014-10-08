class Product
  include Mongoid::Document

  belongs_to :vendor
  has_and_belongs_to_many :users
  has_many :product_tests, dependent: :destroy


  field :name, type: String
  field :version, type: String
  field :description, type: String

  validates_presence_of :name

  def tests_by_cat3
    cat3_tests = {}
    cat1_tests = []
    self.product_tests.each do |p|
      if p.is_a? CalculatedProductTest 
        cat3_tests[p.id] = p
      else
        cat1_tests << p
      end
    end

    if !cat1_tests.empty?
      sorted_tests = cat1_tests.group_by do |p|
        cat3_tests[p.calculated_test_id]
      end
      cat3_tests.each do |id, t|
        sorted_tests[t] = [] if sorted_tests[t].nil?
      end
      return sorted_tests
    else
      return cat3_tests.values.each_with_object([]).to_h
    end
  end

 # a product is only passing if all of it's tests have passed
  def passing?
    return true if self.product_tests.empty?

    passing = self.product_tests.select do |p|
      p.execution_state == :passed
    end
    passing.length == product_tests.length
  end

  #failing if at least one of the tests is failing
  def failing?
    return false if self.product_tests.empty?
    failing = self.product_tests.select do |p|
       p.execution_state == :failed
    end
    failing.length > 0
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
