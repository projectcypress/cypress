# frozen_string_literal: true

# require "cypress/qrda_file_validator"

module Validators
  class QrdaCat1Validator < QrdaFileValidator
    include Validators::Validator
    include ::CqmValidators

    def initialize(bundle, is_c3_validation_task, test_has_c3, test_has_c1, measures = [])
      @test_has_c3 = test_has_c3
      @measures = measures
      qrda_validator = bundle.major_version.to_i > 2021 ? Cat1R53.instance : Cat1R52.instance
      format_validators = [CDA.instance, qrda_validator]
      @validators = if is_c3_validation_task
                      [CqmValidators::DataValidator.new(measures.collect(&:_id))]
                    else
                      format_validators
                    end
      @validators += format_validators if is_c3_validation_task && !test_has_c1
      @validators << CqmValidators::QrdaQdmTemplateValidator.new(bundle.qrda_version)
    end

    # Validates a QRDA Cat I file.  This routine will validate the file against the CDA schema as well as the
    # Generic QRDA Cat I schematron rules and the measure specific rules for each of the measures passed in.
    # THe result will be an Array of execution errors or an empty array if there were no errors.
    def validate(file, options = {})
      @options = options
      doc = get_document(file)
      # validate that each file in the zip contains a valid QRDA Cat I document.
      # We may in the future have to support looking in the contents of the test
      # patient records to match agaist QRDA Cat I documents

      @validators.each do |validator|
        as_warning = (['CqmValidators::QrdaQdmTemplateValidator'].include? validator.class.to_s) && !@test_has_c3 ? true : false
        add_cqm_validation_error_as_execution_error(validator.validate(doc, options),
                                                    validator.class.to_s,
                                                    :xml_validation,
                                                    as_warning: as_warning)
      end
      # dont' validate measures for C1 Checklist or C3 Checklist
      validate_measures(doc) unless %w[C1ChecklistTask C3ChecklistTask].include? options.task._type
      nil
    end

    def validate_measures(doc)
      @measures.each do |measure|
        # Look in the document to see if there is an entry stating that it is reporting on the given measure
        # we will be a bit lenient and look for both the version specific id and the non version specific ids
        measure_xpath = %(//cda:organizer[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.98']]/
              cda:reference[@typeCode='REFR']/cda:externalDocument[@classCode='DOC']/
              cda:id[#{translate('@root')}='2.16.840.1.113883.4.738' and #{translate('@extension')}='#{measure.hqmf_id.upcase}'])
        unless doc.at_xpath(measure_xpath)
          add_error("Document does not state it is reporting measure #{measure.hqmf_id}  - #{measure.description}",
                    validator: 'Validators::QrdaCat1Validator', validator_type: :xml_validation, file_name: @options[:file_name])
        end
      end
    end
  end
end
