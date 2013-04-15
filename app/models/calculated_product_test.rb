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
      pcj = Cypress::PopulationCloneJob.new({'patient_ids' =>p_ids, 'test_id' => test.id, "randomize_names"=> true})
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
      validation_errors.concat ProductTest.match_calculation_results(expected_result,reported_result)
    end    

    te = self.test_executions.build(expected_results:self.expected_results,  reported_results: reported_results, 
                                     matched_results: matched_results, execution_errors: validation_errors)
    te.artifact = Artifact.new(:file => qrda_file)    
    te.save
    
    (te.execution_errors.where({msg_type: :error}).count == 0) ? te.pass : te.failed
    te
  end
  




  def generate_qrda_cat1_test

    self.measures.top_level.each do |mes|
      results = self.results.where({"value.measure_id" => mes.hqmf_id, "value.IPP" => {"$gt" => 0}}).collect{|r| r["value"]["medical_record_id"]} 
      results.uniq!
       qrda = QRDAProductTest.new(measure_ids: [mes.measure_id], 
                               name: "#{self.name} - Measure #{mes.nqf_id} QRDA Cat I Test", 
                               bundle_id: self.bundle_id, 
                               effective_date: self.effective_date,
                               product_id: self.product_id,
                               user_id: self.user_id,
                               calculated_test_id: self.id)
       records = self.records.where({"medical_record_number" => {"$in"=>results}})
       records.each do |rec| 
        new_rec = rec.dup
        new_rec[:test_id] = qrda.id 
        new_rec.save
       end
       qrda.save
       qrda.ready

    end
   
    self[:qrda_generated] = true
    self.save
  end
  
  def self.product_type_measures(bundle)
    bundle.measures.top_level_by_type("ep") #.where({"population_ids.MSRPOPL" => {"$exists" => false}})
  end
  
  
end
