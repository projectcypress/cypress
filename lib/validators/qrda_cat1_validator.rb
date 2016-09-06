# require "cypress/qrda_file_validator"

module Validators
  class QrdaCat1Validator < QrdaFileValidator
    include Validators::Validator
    include HealthDataStandards::Validate

    self.validator = :qrda_cat1

    def initialize(bundle, is_c3_validation_task, test_has_c3, measures = [])
      @test_has_c3 = test_has_c3
      @measures = measures
      @validators = if is_c3_validation_task
                      [HealthDataStandards::Validate::DataValidator.new(bundle, measures.collect(&:hqmf_id))]
                    else
                      bundle.qrda_version == 'r3' ? [CDA.instance, Cat1.instance] : [CDA.instance, Cat1R31.instance]
                    end
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

      validation_errors = @validators.inject([]) do |errors, validator|
        errors.concat validator.validate(doc, options)
      end

      validation_errors.each do |error|
        # errors for data criteria outside the measure definition are now warnings
        type = (error.message.include? 'data criteria outside') ? :warning : :error
        if error.validator && error.validator.upcase.include?('QRDA') && !@test_has_c3
          type = :warning
        end
        add_issue error.message, type, :message => error.message,
                                       :location => error.location, :validator => error.validator,
                                       :validator_type => :xml_validation, :file_name => error.file_name
      end
      # dont' validate measures for C1 Manual or C3 Manual
      validate_measures(doc) unless %w('C1ManualTask', 'C3ManualTask').include? options.task._type
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
          add_error("Document does not state it is reporting measure #{measure.hqmf_id}  - #{measure.name}",
                    :validator => 'Measure Declaration Check', :validator_type => :xml_validation, :file_name => @options[:file_name])
        end
      end
    end
  end
end
