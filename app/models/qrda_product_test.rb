require 'validators/data_criteria_validator'
require 'validators/smoking_gun_validator'
require 'validators/valueset_validator'

class QRDAProductTest < ProductTest
  include Mongoid::Attributes::Dynamic

  def execute(params)

    te = self.test_executions.build(expected_results: self.expected_results, execution_date: Time.now.to_i)
    te.save

    file = params[:results]

    te.artifact = Artifact.create(file: file)

    validation_errors = []
    file_count = 0

    dc_validator = ::Validators::DataCriteriaValidator.new(self.measures)
    sgd_validator = ::Validators::SmokingGunValidator.new(self.measures, self.records, self.id)
    valueset_validator =  ::Validators::ValuesetValidator.new(self.bundle)


    te.artifact.each_file do |name, data|
      doc = Nokogiri::XML(data)
      doc.root.add_namespace_definition("cda", "urn:hl7-org:v3")
      doc.root.add_namespace_definition("sdtc", "urn:hl7-org:sdtc")

      validation_errors.concat sgd_validator.validate(doc,{file_name: name})
      validation_errors.concat dc_validator.validate(doc, {file_name: name})

      errs = Cypress::QrdaUtility.validate_cat_1(doc, measures, name)
      errs.concat valueset_validator.validate(doc)
      errs.each {|e| e[:file_name]=name}
      validation_errors.concat errs
      file_count = file_count + 1
    end

    if file_count != self.records.count
      validation_errors << ExecutionError.new(message: "#{self.records.count} files expected but was #{file_count}", msg_type: :error, validator_type: :result_validation)
    end

    if !sgd_validator.not_found_names.empty?
        validation_errors << ExecutionError.new(message: "Records for patients #{sgd_validator.not_found_names} not found in archive as expected", msg_type: :error, validator_type: :result_validation)
    end


    te.execution_errors = validation_errors

    te.save
    (te.count_errors > 0) ? te.failed : te.pass
    te.save
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
