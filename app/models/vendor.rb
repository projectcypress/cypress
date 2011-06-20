class Vendor

  include Mongoid::Document

  # Vendor Details
  field :name, type: String
  field :address, tyoe: String
  field :state, type: String
  field :zip, type: String
  field :poc, type: String
  field :email, type: String
  field :tel, type: String
  field :fax, type: String
  field :accounts_poc, type: String
  field :accounts_email, type: String
  field :accounts_tel, type: String
  field :tech_poc, type: String
  field :tech_email, type: String
  field :tech_tel, type: String
  field :press_poc, type: String
  field :press_email, type: String
  field :press_tel, type: String
  
  # Proctor Details
  field :proctor, type: String
  field :proctor_tel, type: String
  field :proctor_email, type: String
  
  # Test Details
  field :effective_date, type: Integer
  field :measure_ids, type: Array
  field :patient_gen_job, type: String
  field :reported_results, type: Hash

  # Get the measure definitions for the selected measures. For multinumerator
  # measures this will include all sub measures so measure_defs.size may not be
  # the same as measure_ids.size
  def measure_defs
    return [] if !measure_ids
    measure_ids.collect do |measure_id|
      Measure.where(id: measure_id).order_by([[:sub_id, :asc]]).all()
    end.flatten
  end
  
  # Get the measure definitions for the measures that are failing
  def failing_measures
    measure_defs.select do |measure|
      !passed?(expected_result(measure))
    end
  end
  
  # Get the measure definitions for the measures that are passing
  def passing_measures
    measure_defs.select do |measure|
      passed?(expected_result(measure))
    end
  end

  # Get the reported result for a particular key (e.g. '0038c')
  def reported_result(key)
    default = {'numerator'=>'--', 'denominator'=>'--', 'exclusions'=>'--', 'antinumerator'=>'--'}
    return default if reported_results==nil
    reported_results[key] || default
  end
  
  # Get the expected results for all selected measures
  def expected_results
    measure_defs.collect do |measure|
      expected_result(measure)
    end
  end
  
  # Get the expected result for a particular measure
  def expected_result(measure)
    Cypress::MeasureEvaluator.eval(self, measure)
  end
  
  # Compare the supplied expected results to the reported results and return true
  # if all match, false otherwise
  def passing?
    expected_results.size==count_passing
  end
  
  # Compare the expected results to the stroed reported results and return the
  # count that match
  def count_passing
    passing = expected_results.select do |result|
      passed?(result)
    end
    passing.count
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
  
  # Extract measure results from a PQRI document and add to the reported results
  # for this vendor. Will overwrite existing results for a given measure key
  # @param [Nokogiri::XML::Document] doc the PQRI document
  def extract_reported_from_pqri(doc)
    self.reported_results ||= {}
    result_nodes = doc.xpath('/submission/measure-group/provider/pqri-measure')
    result_nodes.each do |result_node|
      key = result_node.at_xpath('pqri-measure-number').text
      denominator = result_node.at_xpath('eligible-instances').text.to_i
      numerator = result_node.at_xpath('meets-performance-instances').text.to_i
      exclusions = result_node.at_xpath('performance-exclusion-instances').text.to_i
      antinumerator = result_node.at_xpath('performance-not-met-instances').text.to_i
      self.reported_results[key] = {'denominator'=>denominator, 'numerator'=>numerator, 'exclusions'=>exclusions, 'antinumerator'=>antinumerator}
    end
  end
  
end