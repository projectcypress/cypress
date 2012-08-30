class InpatientProductTest < ProductTest
   
  #after the test is created generate the population
  after_create :generate_population
  
  
  #after the test is created generate the population
  after_create :generate_population
  
  def generate_population
    Record.delete_all({test_id: self.id})
    expected_results = {}
    measures.each do |m|
      Record.where({test_id: nil, measure_id: measure.id, type: :eh}).each do |rec|
        cloned = rec.clone
        cloned.test_id = self.id
        cloned.save
      end 
      expected_results[measure.id] = measure.expected_results
    end
  end
  
  
  def execute(params)
    
    file = params[:qrda]
    reported_results = Cypress::QRDAUtil.parse_qrda_cat_3(file)
    te = self.test_executions.build(expected_results: self.expected_results, reported_results: reported_results, execution_errors: validate_results(self.expected_results, reported_results))
    te.save
    te.execution_errors.count > 0 ? te.failed : te.pass
    te
  end
  
  
  def validate_results(expected,reported)
    
  end
  
end