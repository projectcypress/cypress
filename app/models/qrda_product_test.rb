class QRDAProductTest < ProductTest
  
  
  #after the test is created generate the population
  after_create :generate_population
  
  def generate_population
    Record.delete_all({test_id: self.id})
    measures.each do |m|
      rec =  Record.first({test_id: nil, measure_id: measure.id, type: :qrda})
      cloned = rec.clone
      cloned.test_id = self.id
      cloned.save
    end
    
  end
  
  
  
  def execute(params)
    file = params[:qrda]
    te = self.test_executions.build(expected_results: self.expected_results)
    te.execution_errors = Cypress::QRDAUtil.validate_zip(file)
    te.save
    (te.executions_errors.count > 0) ? te.failed : te.pass
    te
    
  end
  
end