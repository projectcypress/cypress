class CalculatedProductTest < ProductTest

  state_machine :state do
    
    after_transition any => :generating_records do |test|
      min_set = PatientPopulation.min_coverage(test.measure_ids)
      p_ids = min_set[:minimal_set]

      #randomly pick a number of other patients to give to the vendor
      #p_ids << minimal_set[:overflow].pick some random peeps
      
      # do this synchronously because it does not take long
      pcj = Cypress::PopulationCloneJob.new("id", {'patient_ids' =>p_ids, 'test_id' => test.id})
      pcj.perform
      #now calculate the expected results
      test.calculate
    end
        
    after_transition any => :calculating_expected_results do |test|
      Cypress::MeasureEvaluationJob.create({"test_id" =>  test.id.to_s})
    end
        
    event :generate_population do
      transition :pending => :generating_records
    end
    
    event :calculate do
      transition :generating_records => :calculating_expected_results
    end
  
  end
  
  #after the test is created generate the population
  after_create :generate_population

  def expected_Results(mesasure_id) 
   (expected_results ||{})[measure_id]
  end


  def execute(params)

    pqri_file = params[:results]
    data = pqri_file.open.read
    reported_results = Cypress::PqriUtility.extract_results(data,nil)  
    pqri_errors = Cypress::PqriUtility.validate(data)  
    
    validation_errors = []
    pqri_errors.each do |e|
      validation_errors << ExecutionError.new(message: e, msg_type: :warning)
    end

    expected_results.each_pair do |key,expected_result|
      reported_result = reported_results[key] || {}
      errs = []
      ['denominator', 'numerator', 'exclusions'].each do |component|
        if reported_result[component] != expected_result[component]
         errs << "expected #{component} value #{expected_result[component]} does not match reported value #{reported_result[component]}"
        end
      end
      if errs
        validation_errors << ExecutionError.new(message: errs.join(",  "), msg_type: :error, measure_id: key )
      end
    end    

    te = self.test_executions.build(expected_results:self.expected_results, execution_date: Time.now.to_i, reported_results: reported_results, execution_errors: validation_errors)
    
    te.save
    ids = Cypress::ArtifactManager.save_artifacts(pqri_file,te)
    te.files = ids
    te.save
    
    (te.execution_errors.where({msg_type: :error}).count == 0) ? te.pass : te.failed
    te
  end
  
  
  
  def self.measures
    Measure.top_level
  end
  
  
  private
  
  # The Measures that are failing for this TestExecution that were selected for the associated ProductTest
   def failing_measures()
     return self.measures.select do |measure|
       !self.passed?(self.expected_result(measure))
     end
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

  
end
