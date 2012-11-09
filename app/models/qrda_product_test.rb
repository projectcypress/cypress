class QRDAProductTest < ProductTest
  after_create :generate_population
  
  def generate_population
    # patient_needs = {self.id => []}
    # all_value_sets = {self.id => []}

    # # This reshapes NLM value sets to the imported value sets that the Test Patient Generator expects from Bonnie. 
    # # TODO Just pass the NLM value sets to the generator once Bonnie is refactored to also use the NLM.
    # oids = self.measures.map{|measure| measure.oids}.flatten.uniq
    # HealthDataStandards::SVS::ValueSet.any_in(oid: oids).each do |value_set|
    #   code_sets = value_set.concepts.map {|concept| {"code_set" => concept.code_system_name, "codes" => [concept.code]}}
    #   all_value_sets[self.id] << {"code_sets" => code_sets, "oid" => value_set.oid}
    # end

    # self.measures.top_level.each do |measure|
    #   puts "Gathering data criteria from #{measure.nqf_id}"
    #   patient_needs[self.id] << measure.data_criteria.map{|dc| HQMF::DataCriteria.from_json(dc.keys.first, dc.values.first)}
    # end
    # patient_needs[self.id].flatten!
    # patient_needs[self.id].uniq!

    # patients = HQMF::Generator.generate_qrda_patients(patient_needs, all_value_sets)
    # patients.each do |measure, patient|
    #   patient.test_id = self.id
    #   patient.save
    # end
    
    # self.ready
      Delayed::Job.enqueue(Cypress::QRDAGenerationJob.new({"test_id" =>  self.id.to_s}))

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

  def measures
    return [] if !measure_ids
    Measure.in(:hqmf_id => measure_ids).top_level.order_by([[:hqmf_id, :asc],[:sub_id, :asc]])
  end
  
  
  def self.product_type_measures
    Measure.top_level
  end
end