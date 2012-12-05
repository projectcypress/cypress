class InpatientProductTest < ProductTest
   
  #after the test is created generate the population
  after_create :generate_population

  
  def generate_population
    self.expected_results = {}
    medical_record_number_mapping = {}
    rand_prefix = Time.new.to_i
    Record.where({test_id: nil, type: :eh}).in(measure_ids: measure_ids).each_with_index do |rec,index|
      cloned = rec.clone
      cloned.test_id = self.id
      mrn = cloned.medical_record_number
      new_mrn = "#{rand_prefix}#{index}"
      medical_record_number_mapping[mrn] = new_mrn
      cloned.medical_record_number = new_mrn

      cloned.save
    end 

    Result.where("value.test_id" => nil).in("value.measure_id" => measure_ids).each do |res|
      cloned = res.clone
      cloned.value["test_id"] = self.id
      mrn = cloned.value["medical_record_id"]
      new_mrn = medical_record_number_mapping[mrn]
      cloned.value["medical_record_id"] = new_mrn
      cloned.save
    end

    measures.each do |measure|

      # todo implement this
      qr = QME::QualityReport.new(measure.hqmf_id, measure.sub_id, 'effective_date' => self.effective_date, 'test_id' => nil, 'filters' => nil)
      if qr.calculated?
       self.expected_results[measure.key] = qr.result.dup
      else
 
      end  
    end
    self.save
    self.ready
  end
  

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
         validation_errors << ExecutionError.new(message: "Could not find entry for measure #{key} ", msg_type: :error, measure_id: key , validator_type: :result_validation)
      end

      matched_result = {measure_id: expected_result["measure_id"], sub_id: expected_results["sub_id"]}
      matched_results[key] = matched_result
      reported_result ||= {}
      errs = []

      _ids = expected_result["population_ids"].dup
      # remove the stratification entry if its there, not needed to test against values
      _ids.delete("stratification")

      
      _ids.keys.each do |pop_key| 
         #pop_key = Cypress::QrdaUtility::POPULATION_CODE_MAPPINGS[pop_id]
        if expected_result[pop_key]
          matched_result[pop_key] = {:expected=>expected_result[pop_key], :reported=>reported_result[pop_key]}
          # only add the error that they dont match if there was an actual result
          if (expected_result[pop_key] != reported_result[pop_key]) && !reported_result.empty?

           errs << "expected #{pop_key} value #{expected_result[pop_key]} does not match reported value #{reported_result[pop_key]}"
          end
        end 
      end
      
      if !errs.empty?
        validation_errors << ExecutionError.new(message: errs.join(",  "), msg_type: :error, measure_id: key , validator_type: :result_validation)
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
  
  
  
  def self.product_type_measures
    Measure.top_level_by_type("eh")
  end
  
end