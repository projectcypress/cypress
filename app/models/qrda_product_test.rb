class QRDAProductTest < ProductTest
  after_create :generate_population
  
  def generate_population
    measure_needs = {}
    measure_value_sets = {}
    self.measures.each do |measure|
      # This reshapes NLM value sets to the imported value sets that the Test Patient Generator expects from Bonnie. 
      # TODO Just pass the NLM value sets to the generator once Bonnie is refactored to also use the NLM.
      value_sets = []
      oids = measures.map{|measure| measure.oids}.flatten.uniq
      HealthDataStandards::SVS::ValueSet.any_in(oid: oids).each do |value_set|
        code_sets = value_set.concepts.map {|concept| {"code_system" => concept.code_system_name, "codes" => [concept.code]}}
        value_sets << {"code_sets" => code_sets}
      end

      measure_needs[measure.id] = measure.data_criteria.map{|dc| HQMF::DataCriteria.from_json(dc.keys.first, dc.values.first)}
      measure_value_sets[measure.id] = value_sets
    end

    patients = HQMF::Generator.generate_qrda_patients(measure_needs, measure_value_sets)
    patients.each do |measure, patient|
      patient.test_id = self.id
      patient.save
    end
    
    self.ready
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