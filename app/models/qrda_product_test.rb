class QRDAProductTest < ProductTest
  after_create :generate_population
  
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
    names = self.records.collect{|r| "#{r.first} #{r.last}".upcase}
    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i) 
    te.save
    
    file = params[:results]
    artifact = Artifact.new(:file=> file, test_execution: te)
    artifact.save
    te.artifact = artifact
    validation_errors = []
    file_count = 0

    # collect the datacriteria oids for the measures being tested to see if there are any extra data elements in the qrda
    oids = self.measures.collect{|m| m.oids}.flatten.uniq
    artifact.each_file do |name, data|
      doc = Nokogiri::XML(data) 
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")
      first = doc.at_xpath("/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:given/text()")
      last = doc.at_xpath("/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:name/cda:family/text()")
      doc_name = "#{first.to_s} #{last.to_s}".upcase
      
      unless names.index(doc_name)
         validation_errors << ExecutionError.new(message: "Pateint name '#{doc_name}' declared in file not found in test records'", msg_type: :error, validator_type: :result_validation, file_name: name)
      end
      
      reported_oids = doc.xpath("//@sdtc:valueSet").collect{|att| att.value}.uniq

      # check for oids in the document not in the meausures
      disjoint_oids = reported_oids - oids
      if !disjoint_oids.empty?
        validation_errors << ExecutionError.new(message: "File appears to contain data criteria outside that required by the measures #{disjoint_oids}'", msg_type: :error, validator_type: :result_validation, file_name: name)
      end

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