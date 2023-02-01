# frozen_string_literal: true

module Validators
  class EncounterValidator < QrdaFileValidator
    include Validators::Validator

    def validate(file, options = {})
      doc = get_document(file)
      encounter_times = doc.xpath("//cda:encounter[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.23']/cda:effectiveTime")
      encounter_times.each do |encounter|
        begin
          low = validate_encounter_time('low', 'start', encounter, options[:file_name])
          high = validate_encounter_time('high', 'end', encounter, options[:file_name])
        rescue StandardError
          next
        end
        validate_encounter_start_end(encounter.path, low, high, options[:file_name])
      end
    end

    def validate_encounter_time(type, title, encounter, file)
      begin
        val = get_time_value(encounter, type, file)
      rescue ArgumentError => e
        add_error("Encounter #{title} time invalid. #{e.message}", location: encounter.path, file_name: file)
        throw e
      rescue NoMethodError
        add_error("No encounter #{title} time found.", location: encounter.path, file_name: file) unless encounter.at_xpath('./cda:low/@nullFlavor')
        throw e
      end
      val
    end

    def validate_encounter_start_end(path, low, high, file)
      current_time = Time.now.utc
      if low > high
        # encounter ends before start time
        add_error("Encounter ends (#{format_time(high)}) before start time (#{format_time(low)})",
                  location: path, file_name: file)
      elsif low > current_time || high > current_time
        # encounter occurs in the future
        add_error("Encounter occurs in the future (#{format_time(low)})", location: path, file_name: file)
      end
    end

    def format_time(time_i)
      time = Time.at(time_i).utc
      time.strftime('%-m/%-d/%Y %k:%M')
    end

    def get_time_value(time_el, value_el, file)
      timestamp = time_el.at_xpath("./cda:#{value_el}/@value").value
      unless [12, 14, 19].include? timestamp.length
        case value_el
        when 'low'
          add_error("CMS_0075 - Fails validation check for Encounter Performed Admission Date (effectiveTime/low value)
            as specified in Table 14: Valid Date/Time Format for HQR.", location: time_el.path, file_name: file)
        when 'high'
          add_error("CMS_0076 - Fails validation check for Encounter Performed Discharge Date (effectiveTime/high value)
            as specified in Table 14: Valid Date/Time Format for HQR.", location: time_el.path, file_name: file)
        end
      end
      DateTime.parse(timestamp).utc
    end
  end
end
