module Validators
  class MeasurePeriodValidator < QrdaFileValidator
    include Validators::Validator

    self.validator = :measure_period

    def initialize
    end

    def validate(file, options = {})
      @document = get_document(file)
      @options = options
      validate_measurement_period
    end

    def validate_measurement_period
      validate_start
      validate_end
    end

    def validate_start
      measure_start = Cypress::AppConfig['effective_date']['year'].to_s + '0101'
      doc_start_time = @document.at_xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/
        cda:entry/cda:act[./cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8']]/
        cda:effectiveTime/cda:low/@value")
      if !doc_start_time
        msg = 'Document needs to report the Measurement Start Date'
        add_error(msg, :location => '/', :validator_type => :submission_validation, :file_name => @options[:file_name])
      else
        unless doc_start_time.value.to_s.start_with? measure_start
          msg = "Reported Measurement Period should start on #{measure_start}"
          add_error(msg, :location => '/', :validator_type => :submission_validation, :file_name => @options[:file_name])
        end
      end
    end

    def validate_end
      measure_end = Cypress::AppConfig['effective_date']['year'].to_s + '1231'
      doc_end_time = @document.at_xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/
        cda:entry/cda:act[./cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8']]/
        cda:effectiveTime/cda:high/@value")
      if !doc_end_time
        msg = 'Document needs to report the Measurement End Date'
        add_error(msg, :location => '/', :validator_type => :submission_validation, :file_name => @options[:file_name])
      else
        unless doc_end_time.value.to_s.start_with? measure_end
          msg = "Reported Measurement Period should end on #{measure_end}"
          add_error(msg, :location => '/', :validator_type => :submission_validation, :file_name => @options[:file_name])
        end
      end
    end
  end
end
