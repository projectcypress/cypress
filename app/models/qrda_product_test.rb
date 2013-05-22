require 'validators/data_criteria_validator'
require 'validators/smoking_gun_validator'
class QRDAProductTest < ProductTest
  after_create :generate_population
  # oids declared in the spec not by the measures -- will want  to filter these out of the checks
  

  def generate_population
    unless self["calculated_test_id"]

      min_set = PatientPopulation.min_coverage(self.measure_ids, self.bundle)
      p_ids = min_set[:minimal_set]
      pcj = Cypress::PopulationCloneJob.new({'patient_ids' =>p_ids, 'test_id' => self.id, "randomize_names"=> (Rails.env.test? ? false : true)})
      pcj.perform
      #now calculate the expected results
      self.ready
    end
  end
  
  def execute(params)
    record_count = self.records.count

    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i) 
    te.save
    
    file = params[:results]
    artifact = Artifact.new(:file=> file, test_execution: te)
    artifact.save
    te.artifact = artifact
    validation_errors = []
    file_count = 0

    dc_validator = ::Validators::DataCriteriaValidator.new(self.measures)
    sgd_validator = ::Validators::SmokingGunValidator.new(self.measures, self.records, self.id)
    artifact.each_file do |name, data|
      doc = Nokogiri::XML(data) 
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")
      
      validation_errors.concat sgd_validator.validate(doc,{file_name: name})
      validation_errors.concat dc_validator.validate(doc, {file_name: name})

      errs = Cypress::QrdaUtility.validate_cat_1(doc, measures, name)
      errs.each {|e| e[:file_name]=name}
      validation_errors.concat errs
      file_count = file_count + 1
    end
   
    if file_count != record_count
      validation_errors << ExecutionError.new(message: "#{record_count} files expected but was #{file_count}", msg_type: :error, validator_type: :result_validation)
    end
    
    te.execution_errors = validation_errors
    
    te.save
    (te.count_errors > 0) ? te.failed : te.pass
    te
  end

  def measures
    return [] if !measure_ids
    self.bundle.measures.in(:hqmf_id => measure_ids).top_level.order_by([[:hqmf_id, :asc],[:sub_id, :asc]])
  end
  
  
  def self.product_type_measures(bundle)
    bundle.measures.top_level
  end


end