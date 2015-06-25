module Validators
    class MeasurePeriodValidator < QrdaFileValidator
        include Validators::Validator

        def initialize()
        end

        def validate(file, options={})
          @document = get_document(file)
          @options = options
          validate_measurement_period()
        end

        def validate_measurement_period()
          validation_errors = []
          measure_start = APP_CONFIG['effective_date']['year'].to_s + "0101"
          measure_end = APP_CONFIG['effective_date']['year'].to_s + "1231"
          if !@document.at_xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry
            /cda:act[./cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8']]/cda:effectiveTime/cda:low/@value").value.to_s.include? measure_start
            msg = "Reported Measurement Period should start on #{measure_start}"
            add_error(msg,{:location=>"/",:validator_type=>:xml_validation, file_name: @options[:file_name]})
          end
          if !@document.at_xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry
            /cda:act[./cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8']]/cda:effectiveTime/cda:high/@value").value.to_s.include? measure_end
            msg = "Reported Measurement Period should end on #{measure_end}"
            add_error(msg,{:location=>"/",:validator_type=>:xml_validation, file_name: @options[:file_name]})
           end
        end
    end
end