class QRDAProductTest < ProductTest
  
  
  #after the test is created generate the population
  after_create :generate_population
  
  def generate_population
    measures.each do |measure|
      Record.where({test_id: nil, measure_id: measure["id"], type: :qrda}).each do |rec|
        cloned = rec.clone
        cloned.test_id = self.id
        cloned.save
      end
    end
    
  end
  
  
  
  def execute(params)
    file = params[:results]
    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i)
    te.execution_errors = Cypress::QRDAUtility.validate_zip(file)
    
    ids = Cypress::ArtifactManager.save_artifacts(file,te)
    te.files = ids
    te.save

    (te.count_errors > 0) ? te.failed : te.pass
    te
    
  end
  
  
  def self.measures
    Measure.top_level
  end
  
end