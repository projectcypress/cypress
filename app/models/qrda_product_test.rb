class QRDAProductTest < ProductTest
  after_create :generate_population
  
  def generate_population
    # TODO change this over to use test patient generator from bonnie as shown below
    self.measures.each do |measure|
      Record.where({test_id: nil, measure_id: measure.id, type: :qrda}).each do |rec|
        cloned = rec.clone
        cloned.test_id = self.id
        cloned.save
      end
    end
    
    # measure_needs = {}
    # measure_value_sets = {}
    # self.measures.each do |measure|
    #   measure_needs[measure.id] = measure.data_criteria.map{|dc| HQMF::DataCriteria.from_json(dc.keys.first, dc.values.first)}
    #   measure_value_sets[measure.id] = measure.value_sets
    # end
      
    # patients = HQMF::Generator.generate_qrda_patients(measure_needs, measure_value_sets)
    # patients.each do |measure, patient|
    #   patient.test_id = self.id
    #   patient.save
    # end
  end
  
  def execute(params)
    file = params[:results]
    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i)
    te.execution_errors = Cypress::QrdaUtility.validate_cat_1(file.open.read, measures, "results")
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