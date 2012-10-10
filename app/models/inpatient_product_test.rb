class InpatientProductTest < ProductTest
   
  #after the test is created generate the population
  after_create :generate_population

  
  def generate_population
    expected_results = {}
    measures.each do |measure|
      Record.where({test_id: nil, measure_id: measure.hqmf_id, type: :eh}).each do |rec|
        cloned = rec.clone
        cloned.test_id = self.id
        cloned.save
      end 
      # todo implement this
      qr = QME::QualityReport.new(measure.hqmf_id, measure.sub_id, 'effective_date' => product_test.effective_date, 'test_id' => nil, 'filters' => [])
      if qr.calculated?
       expected_results[measure.key] = qr.report.dup
      else
        expected_results[measure.key]  = {}
      end  
    end
    self.save
    self.ready
  end
  

def execute(params)

   

    te = self.test_executions.build(expected_results:self.expected_results,  reported_results: {}, execution_errors: [])
    
    te.save
    
    (te.execution_errors.where({msg_type: :error}).count == 0) ? te.pass : te.failed
    te
  end
  
  
  
  def self.product_type_measures
    Measure.top_level_by_type("eh")
  end
  
end