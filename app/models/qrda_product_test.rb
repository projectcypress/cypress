class QRDAProductTest < ProductTest
  
  
  #after the test is created generate the population
  after_create :generate_population
  
  def generate_population
    # To-DO change this over to sue test patient generator from bonnie
    # give it the set of data criteria required for the selected measures and generate 
    # a single patient record for the measures
    self.measures.each do |measure|
      Record.where({test_id: nil, measure_id: measure.id, type: :qrda}).each do |rec|
        cloned = rec.clone
        cloned.test_id = self.id
        cloned.save
      end
    end
    
  end
  
  def execute(params)
    file = params[:results]
    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i)
    te.execution_errors = Cypress::QRDAUtility.validate_cat_1("results",file.open.read)
    ids = Cypress::ArtifactManager.save_artifacts(file,te)
    te.file_ids = ids
    te.save
    (te.count_errors > 0) ? te.failed : te.pass
    te
    
  end
  
  def self.product_type_measures
    Measure.top_level
  end

 
end