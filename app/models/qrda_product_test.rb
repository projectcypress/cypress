class QRDAProductTest < ProductTest
  after_create :generate_population
  # oids declared in the spec not by the measures -- will want  to filter these out of the checks
  HL7_QRDA_OIDS = ["2.16.840.1.113883.3.221.5",
  "2.16.840.1.113883.3.88.12.3221.8.7",
  "2.16.840.1.113883.3.88.12.3221.8.9",
  "2.16.840.1.113883.1.11.12839",
  "2.16.840.1.113883.3.88.12.3221.8.11",
  "2.16.840.1.113883.3.88.12.3221.6.2",
  "2.16.840.1.113883.11.20.9.40",
  "2.16.840.1.113883.11.20.9.23",
  "2.16.840.1.113883.3.88.12.3221.7.4",
  "2.16.840.1.113883.11.20.9.18",
  "2.16.840.1.113883.11.20.9.22",
  "2.16.840.1.113883.1.11.16866",
  "2.16.840.1.113883.1.11.20275",
  "2.16.840.1.113883.11.20.9.34",
  "2.16.840.1.113883.3.88.12.3221.7.2",
  "2.16.840.1.113883.3.88.12.80.17",
  "2.16.840.1.113883.3.88.12.80.22",
  "2.16.840.1.113883.3.88.12.80.64",
  "2.16.840.1.113883.3.88.12.3221.6.8",
  "2.16.840.1.113883.1.11.78",
  "2.16.840.1.113883.11.20.9.25",
  "2.16.840.1.113883.11.20.9.39",
  "2.16.840.1.113883.3.88.12.80.32",
  "2.16.840.1.113883.11.20.9.21",
  "2.16.840.1.113883.3.88.12.80.68",
  "2.16.840.1.113883.1.11.20.12",
  "2.16.840.1.113883.11.20.9.24",
  "2.16.840.1.113883.11.20.9.41",
  "2.16.840.1.113883.1.11.16926",
  "2.16.840.1.113883.1.11.12212",
  "2.16.840.1.113883.1.11.19185",
  "2.16.840.1.113883.1.11.14914",
  "2.16.840.1.114222.4.11.837",
  "2.16.840.1.113883.1.11.19563",
  "2.16.840.1.113883.1.11.11526",
  "2.16.840.1.113883.11.20.9.20",
  "2.16.840.1.113883.3.88.12.80.2",
  "2.16.840.1.113883.3.88.12.80.63",
  "2.16.840.1.113883.1.11.12249",
  "2.16.840.1.113883.1.11.1",
  "2.16.840.1.113883.1.11.12199",
  "2.16.840.1.113883.11.20.9.33",
  "2.16.840.1.114222.4.11.1066",
  "2.16.840.1.113883.1.11.19579"]


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
      disjoint_oids = reported_oids - HL7_QRDA_OIDS - oids
      if !disjoint_oids.empty?
        validation_errors << ExecutionError.new(message: "File appears to contain data criteria outside that required by the measures. Valuesets in file not in measures tested #{disjoint_oids}'", msg_type: :error, validator_type: :result_validation, file_name: name)
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