class TestExecution
  include Mongoid::Document

  belongs_to :product_test


  field :execution_date, type: Integer
  field :baseline_results, type: Hash
  field :reported_results, type: Hash
  field :validation_errors, type: Array
  field :baseline_validation_errors, type: Array
  
  validates_presence_of :execution_date
  # A TestExecution is passing if the number of p
  def passing?
    return self.expected_results.size == self.count_passing
  end

  # A TestExecution is incomplete if no reported results
  def incomplete?
    return self.reported_results.nil?
  end
  
  # Compare the expected results to the stroed reported results and return the
  # count that match
  def count_passing
    num_passing_measures = 0
    
    self.expected_results.each do |result|
      num_passing_measures += 1 if self.passed?(result)
    end
    
    return num_passing_measures
  end
  
  # Compare the supplied expected result to the reported result and return true
  # if all figures match, false otherwise
  def passed?(expected_result)
    reported_result = reported_result(expected_result['key'])
    ['denominator', 'numerator', 'exclusions'].each do |component|
      if reported_result[component] != expected_result[component]
        #puts "reported: #{reported_result[component]} , expected: #{expected_result[component]}"
        return false
      end
    end
    
    return true
  end
  
  # The Measures that are passing for this TestExecution that were selected for the associated ProductTest
  def passing_measures
    return self.product_test.measure_defs.select do |measure|
      self.passed?(self.expected_result(measure))
    end
  end
  
  # The Measures that are failing for this TestExecution that were selected for the associated ProductTest
  def failing_measures
    return self.product_test.measure_defs.select do |measure|
      !self.passed?(self.expected_result(measure))
    end
  end
  
  # Get the reported result for a particular key (e.g. '0038c')
  def reported_result(key)
    default = {'numerator' => '--', 'denominator' => '--', 'exclusions' => '--', 'antinumerator' => '--'}
    
    if self.reported_results == nil
      return default
    else
      return self.reported_results[key] || default
    end
  end
  
  # Get the expected results for all selected measures
  def expected_results
    return self.product_test.measure_defs.collect do |measure|
      expected_result(measure)
    end
  end
  
  # Get the expected result for a particular measure
  def expected_result(measure)
    Cypress::MeasureEvaluator.eval(self.product_test, measure)
  end
  
  # A prettier version of the execution_date field
  def pretty_date
    return Time.at(self.execution_date).strftime("%m/%d/%Y - %l:%M:%S %p")
  end
  
  # The percentage of passing measures. Returns 0 if this is a new, yet to be run TestExecution
  def success_rate
    return 0 if self.reported_results.nil?
    return self.count_passing.to_f / self.product_test.measure_ids.size
  end
  
  # This function is used to normalize test results that first import a baseline.
  # We'll be subtracting the results from the baseline and replacing the reported results with those values.
  def normalize_results_with_baseline
    self.baseline_results.each do |measure, baseline_result|
      if (self.reported_results[measure])
        self.reported_results[measure]['denominator'] -= baseline_result['denominator']
        self.reported_results[measure]['numerator'] -= baseline_result['numerator']
        self.reported_results[measure]['exclusions'] -= baseline_result['exclusions']
        self.reported_results[measure]['antinumerator'] -= baseline_result['antinumerator']
      end
    end
  end
end
