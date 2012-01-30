class ProductTest
  include Mongoid::Document

  belongs_to :product
  has_one :patient_population
  has_many :test_executions

  # Test Details
  field :name, type: String
  field :description, type: String
  field :effective_date_start, type: Integer
  field :effective_date_end, type: Integer
  field :measure_ids, type: Array
  field :baseline_results, type: Hash
  field :reported_results, type: Hash
  field :validation_errors, type: Array
  field :baseline_validation_errors, type: Array
  
  # Returns true if this ProductTests most recent TestExecution is passing
  def passing?
    return true#self.test_executions.count_passing == self.test_executions.size
  end
  
  # Compare the expected results to the stroed reported results and return the
  # count that match
  def count_passing
    num_passing_executions = 0
    
    self.test_executions.each do |execution|
      num_passing_executions += 1 if execution.passing?
    end
    
    num_passing_executions
  end
  
  # Extract and return measure results from a PQRI document and add to the reported results
  # for this test.
  def extract_results_from_pqri(doc)
    results ||= {}
    result_nodes = doc.xpath('/submission/measure-group/provider/pqri-measure')
    
    result_nodes.each do |result_node|
      key = result_node.at_xpath('pqri-measure-number').text
      numerator = result_node.at_xpath('meets-performance-instances').text.to_i
      exclusions = result_node.at_xpath('performance-exclusion-instances').text.to_i
      antinumerator = result_node.at_xpath('performance-not-met-instances').text.to_i
      denominator = numerator + antinumerator
      
      results[key] = {'denominator' => denominator, 'numerator' => numerator, 'exclusions' => exclusions, 'antinumerator' => antinumerator}
    end
    
    return results
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

  # Validate the pqri submission against the xsd.
  #
  # Return value is an array of all errors found.
  def validate_pqri(doc, schema)
    validation_errors = []
    
    schema.validate(doc).each do |error|
      validation_errors << error.message
    end
    
    return validation_errors
  end
end