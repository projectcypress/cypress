module Validators
  class MeasurePeriodValidator < QrdaFileValidator
    include Validators::Validator

    # All Encounter end times
    DISCHARGE_SELECTOR = "//cda:encounter[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.23']]/cda:effectiveTime/cda:high/@value".freeze

    # All Procedure end times
    PROCEDURE_SELECTOR = "//cda:procedure[./cda:templateId[@root='2.16.840.1.113883.10.20.24.3.64']]/cda:effectiveTime/cda:high/@value".freeze

    def initialize; end

    def validate(file, options = {})
      @document = get_document(file)
      @options = options
      @product_test = @options['test_execution'].task.product_test
      @doc_start_time = measure_period_start(@document)
      @doc_end_time = measure_period_end(@document)
      if (@product_test.is_a? CMSProgramTest) && @product_test.reporting_program_type == 'eh'
        # For EH measures, Reports are for a single quarter
        validate_quarters_measurement_period
        # For EH measures, and enounter or procedure needs to end during the quarter reported
        validate_encounter_during_reporting_period
      else
        # Otherwise, measurement period should be for the correct year.
        validate_measurement_period
      end
    end

    def validate_measurement_period
      # Validate that start and end date are reported
      validate_start
      validate_end
    end

    def validate_start
      # Precise to day
      measure_start = Time.at(@product_test.measure_period_start).utc.strftime('%Y%m%d')
      if !@doc_start_time
        msg = 'Document needs to report the Measurement Start Date'
        add_error(msg, error_options)
      else
        unless @doc_start_time.value.to_s.start_with? measure_start
          msg = "Reported Measurement Period should start on #{measure_start}"
          add_error(msg, error_options)
        end
      end
    end

    def validate_end
      # Precise to day
      measure_end = Time.at(@product_test.effective_date).utc.strftime('%Y%m%d')
      if !@doc_end_time
        msg = 'Document needs to report the Measurement End Date'
        add_error(msg, error_options)
      else
        unless @doc_end_time.value.to_s.start_with? measure_end
          msg = "Reported Measurement Period should end on #{measure_end}"
          add_error(msg, error_options)
        end
      end
    end

    def validate_quarters_measurement_period
      measure_year = Time.at(@product_test.measure_period_start).utc.strftime('%Y')
      quarters = [%w[0101 0331], %w[0401 0630], %w[0701 0930], %w[1001 1231]]

      matches_quarter = false

      quarters.each do |quarter|
        measure_start = measure_year + quarter[0]
        measure_end = measure_year + quarter[1]

        # Set matches_quarter to true when a correctly reported quarter is found
        if @doc_start_time.value.to_s.start_with?(measure_start) && @doc_end_time.value.to_s.start_with?(measure_end)
          matches_quarter = true
          break
        end
      end

      # Return error message is reported quarter cannot be found
      unless matches_quarter
        msg = "Reported Measurement Period (#{@doc_start_time} - #{@doc_end_time}) does not align to a quarter " \
              '(ex, 1/1-3/31, 4/1-6/30, 7/1-9/30, 10/1-12/31).'
        add_error(msg, error_options)
      end
    end

    def validate_encounter_during_reporting_period
      # pick all the discharge dates and make sure at least one falls within the reporting period
      discharge_dates = @document.xpath(DISCHARGE_SELECTOR).collect(&:value)
      discharge_dates += @document.xpath(PROCEDURE_SELECTOR).collect(&:value)

      rp_start_date, rp_end_date = formatted_start_and_end(@doc_start_time, @doc_end_time)

      any_date_within_period = false
      discharge_dates.each do |discharge|
        discharge_date = DateTime.parse(discharge).in_time_zone

        if rp_start_date <= discharge_date && discharge_date <= rp_end_date
          any_date_within_period = true
          break
        end
      end

      unless any_date_within_period
        msg = 'Documents must contain at least one encounter or procedure with a discharge date during the reporting period'
        add_error(msg, error_options)
      end
    end

    def formatted_start_and_end(rp_start, rp_end)
      rp_start_date = DateTime.parse(rp_start).in_time_zone
      rp_end_date = DateTime.parse(rp_end).in_time_zone
      [rp_start_date.change(hour: 0, min: 0, sec: 0), rp_end_date.change(hour: 23, min: 59, sec: 59)]
    end

    def measure_period_start(document)
      document.at_xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/
        cda:entry/cda:act[./cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8']]/
        cda:effectiveTime/cda:low/@value")
    end

    def measure_period_end(document)
      document.at_xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/
        cda:entry/cda:act[./cda:templateId[@root='2.16.840.1.113883.10.20.17.3.8']]/
        cda:effectiveTime/cda:high/@value")
    end

    private

    def error_options
      { location: '/',
        validator_type: :submission_validation,
        file_name: @options[:file_name] }
    end
  end
end
