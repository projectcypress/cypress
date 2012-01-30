class TestExecution
  include Mongoid::Document

  belongs_to :product_test
  has_many :results

  # Test Details
  field :execution_date, type: Integer
  field :baseline_results, type: Hash
  field :reported_results, type: Hash
  field :validation_errors, type: Array
  field :baseline_validation_errors, type: Array
  
  # A TestExecution is passing if the number of p
  def passing?
    return self.expected_results.size == self.count_passing
  end
  
  # Compare the expected results to the stroed reported results and return the
  # count that match
  def count_passing
    num_passing_measures = 0
    
    self.expect_results.each do |result|
      num_passing_measures += 1 if self.passed?(result)
    end
    
    return passing.count
  end
  
  # Compare the supplied expected result to the reported result and return true
  # if all figures match, false otherwise
  def passed?(expected_result)
    passed = true
    reported_result = reported_result(expected_result['key'])
    ['denominator', 'numerator', 'exclusions'].each do |component|
      if reported_result[component] != expected_result[component]
        passed = false
      end
    end
    passed
  end
  
  # Get the expected results for all selected measures
  def expected_results
    measure_defs.collect do |measure|
      expected_result(measure)
    end
  end
  
  # Get the expected result for a particular measure
  def expected_result(measure)
    Cypress::MeasureEvaluator.eval(self.product_test, measure)
  end
end