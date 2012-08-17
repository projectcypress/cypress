class CalculatedProductTest < ProductTest

  state_machine :state do
    
    after_transition any => :generating_records do |test|
      puts "generating records"
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
      #calculate the results
      puts "calculating results"
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
  

  
end
