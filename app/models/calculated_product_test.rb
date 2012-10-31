class CalculatedProductTest < ProductTest

  state_machine :state do
    
    after_transition any => :generating_records do |test|

      min_set = PatientPopulation.min_coverage(test.measure_ids)
      p_ids = min_set[:minimal_set]

      #randomly pick a number of other patients to give to the vendor
      #p_ids << minimal_set[:overflow].pick some random peeps
      
      # do this synchronously because it does not take long
     # p_ids = Record.where(:test_id=>nil, :type=>"ep").collect{|p| p.medical_record_number}
      pcj = Cypress::PopulationCloneJob.new({'patient_ids' =>p_ids, 'test_id' => test.id})
      pcj.perform
      #now calculate the expected results
      test.calculate
    end
        
    after_transition any => :calculating_expected_results do |test|
      Delayed::Job.enqueue(Cypress::MeasureEvaluationJob.new({"test_id" =>  test.id.to_s}))
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


  def execute(params)

    qrda_file = params[:results]
    data = qrda_file.open.read
    doc = Nokogiri::XML(data)
    
    matched_results = {}
    reported_results = {}
    
    validation_errors = Cypress::QrdaUtility.validate_cat3(data) || [] 
 
   
    
    expected_results.each_pair do |key,expected_result|
      result_key = expected_result["population_ids"].dup
      reported_result = Cypress::QrdaUtility.extract_results_by_ids(doc,expected_result["measure_id"], result_key) 
      reported_results[key] = reported_result 

      if reported_result.nil?
         validation_errors << ExecutionError.new(message: "Could not find entry for measure #{key} ", msg_type: :error, measure_id: key )
      end

      matched_result = {measure_id: expected_result["measure_id"], sub_id: expected_results["sub_id"]}
      matched_results[key] = matched_result
      reported_result ||= {}
      errs = []

      _ids = expected_result["population_ids"].dup
      # remove the stratification entry if its there, not needed to test against values
      _ids.delete("stratification")
      _ids.keys.each do |pop_id| 
         key = Cypress::QrdaUtility::POPULATION_CODE_MAPPINGS[pop_id]
        if expected_result[key]
          matched_result[key] = {:expected=>expected_result[key.to_s], :reported=>reported_result[:key.to_sym]}
          # only add the error that they dont match if there was an actual result
          if (expected_result[key.to_s] != reported_result[key.to_sym]) && !reported_result.empty?

           errs << "expected #{key} value #{expected_result[key.to_s]} does not match reported value #{reported_result[key.to_sym]}"
          end
        end 
      end
      if !errs.empty?
        validation_errors << ExecutionError.new(message: errs.join(",  "), msg_type: :error, measure_id: key )
      end
    end    

    te = self.test_executions.build(expected_results:self.expected_results,  reported_results: reported_results,  matched_results: matched_results, execution_errors: validation_errors)
    ids = Cypress::ArtifactManager.save_artifacts(qrda_file,te)
    te.file_ids = ids
    te.save
    
    (te.execution_errors.where({msg_type: :error}).count == 0) ? te.pass : te.failed
    te
  end
  
  
  def self.product_type_measures
    Measure.top_level_by_type("ep")
  end
  
  
end
