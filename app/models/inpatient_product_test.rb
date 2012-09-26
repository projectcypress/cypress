class InpatientProductTest < ProductTest
   
  #after the test is created generate the population
  after_create :generate_population
  after_create :fake_expected_results
  
  def fake_expected_results
    self.expected_results = {}
    self.save!
  end
  
  def generate_population
    expected_results = {}
    measures.each do |measure|
      Record.where({test_id: nil, measure_id: measure["id"], type: :eh}).each do |rec|
        cloned = rec.clone
        cloned.test_id = self.id
        cloned.save
      end 
      # todo implement this
      expected_results[measure.id] = {}
    end
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

  
  
  def validate_results(expected,reported)
    
  end
  
   def self.product_type_measures
    Measure.top_level_by_type("eh")
  end
  
end