class CalculatedProductTest < ProductTest

  state_machine :state do
    
    after_transition any => :generating_records do |test|
      min_set = PatientPopulation.min_coverage(test.measure_ids, test.bundle)
      p_ids = min_set[:minimal_set]
      ptype = test.kind_of?(InpatientProductTest) ?  "eh" : "ep"
      if p_ids.length < 5
        r_ids = test.bundle.records.where({}).collect {|r| r.medical_record_number}
        while p_ids.length < 5
          p_ids << r_ids.sample
        end
      end
      #randomly pick a number of other patients to give to the vendor
      #p_ids << minimal_set[:overflow].pick some random peeps
      
      # do this synchronously because it does not take long
      # p_ids = Record.where(:test_id=>nil, :type=>"ep").collect{|p| p.medical_record_number}
      pcj = Cypress::PopulationCloneJob.new({'patient_ids' =>p_ids, 'test_id' => test.id, "randomize_names"=> false})
      pcj.perform
      #now calculate the expected results
      test.calculate
    end
        
    after_transition any => :calculating_expected_results do |test|
      test.status_message = "Calculating Measures"
      test.save
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
      reported_result, errors = Cypress::QrdaUtility.extract_results_by_ids(doc,expected_result["measure_id"], result_key) 
      reported_results[key] = reported_result 
     
      
      if reported_result.nil? || reported_result.keys.length <=1
        message = "Could not find entry for measure #{expected_result["measure_id"]} with the following population ids "   
        message +=  result_key.inspect
        validation_errors << ExecutionError.new(message: message, msg_type: :error, measure_id: expected_result["measure_id"] , stratification: result_key['stratification'], validator_type: :result_validation)
      end

      matched_result = {measure_id: expected_result["measure_id"], sub_id: expected_results["sub_id"]}
      matched_results[key] = matched_result
      reported_result ||= {}
      errs = []

      _ids = expected_result["population_ids"].dup
      # remove the stratification entry if its there, not needed to test against values
      stratification = _ids.delete("stratification")

      
      _ids.keys.each do |pop_key| 
         #pop_key = Cypress::QrdaUtility::POPULATION_CODE_MAPPINGS[pop_id]

        if !expected_result[pop_key].nil?
          matched_result[pop_key] = {:expected=>expected_result[pop_key], :reported=>reported_result[pop_key]}
          # only add the error that they dont match if there was an actual result
          if !reported_result.empty? && !reported_result.has_key?(pop_key)
            message = "Could not find value"
            message += " for stratification #{stratification} " if stratification
            message += " for Population #{pop_key}"
            validation_errors << ExecutionError.new(message: message, msg_type: :error, measure_id: expected_result["measure_id"] , validator_type: :result_validation, stratification: stratification)
          elsif (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?
           err = "expected #{pop_key} #{_ids[pop_key]} value #{expected_result[pop_key]} does not match reported value #{reported_result[pop_key]}"
           validation_errors << ExecutionError.new(message: err, msg_type: :error, measure_id: expected_result["measure_id"] , validator_type: :result_validation, stratification: stratification)
          end
        end 
      end
      if !errs.empty?
        
      end
    end    

    te = self.test_executions.build(expected_results:self.expected_results,  reported_results: reported_results, 
                                     matched_results: matched_results, execution_errors: validation_errors)
    ids = Cypress::ArtifactManager.save_artifacts(qrda_file,te)
    te.file_ids = ids
    te.save
    
    (te.execution_errors.where({msg_type: :error}).count == 0) ? te.pass : te.failed
    te
  end
  
  
  def self.product_type_measures(bundle)
    bundle.measures.top_level_by_type("ep") #.where({"population_ids.MSRPOPL" => {"$exists" => false}})
  end
  
  
end
