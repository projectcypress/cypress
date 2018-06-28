module RecordsHelper
  SECTIONS = %w[adverse_event allergy assessment care_experience care_goal communication condition
                device diagnostic_study encounter family_history functional_status immunization intervention
                laboratory_test medical_equipment medication physical_exam preference provider_characteristic
                procedure result risk_category_assessment social_history substance symptom system_characteristic
                transfer vital_sign].freeze
  FIELDS = %w[name principalDiagnosis values dose dischargeDisposition route
              administrationTiming fulfillmentHistory reason direction ordinality
              transferFrom laterality anatomical_location diagnosis].freeze
  SUBFIELDS = %w[title scalar value unit units description period dispenseDate quantityDispensed time].freeze
  CV_POPULATION_KEYS = %w[IPP MSRPOPL MSRPOPLEX OBSERV].freeze
  PROPORTION_POPULATION_KEYS = %w[IPP DENOM NUMER DENEX DENEXCEP].freeze

  def full_gender_name(gender)
    case gender
    when 'M'
      'Male'
    when 'F'
      'Female'
    else
      ''
    end
  end

  def full_name(patient)
    patient.givenNames.join(' ') + ' ' + patient.familyName if patient
  end

  def pop_sum(records, measure, population)
    records.reduce(0) do |sum, r|
      result_value = get_result_value(r.calculation_results, measure, population)
      if result_value
        sum + result_value
      else
        sum
      end
    end
  end

  def get_result_value(results, measure, population)
    result_value = results.where('measure' => measure._id)
    result_value.first[population].to_i if result_value.first
  end

  def records_by_measure(records, measure)
    # Returns array of records that have at least one calculation result for the given measure id
    records.reject { |r| r.calculation_results.where('measure' => measure._id).empty? }
  end

  def display_field(field)
    display_text = ''
    return '' if field.nil?
    return field if field.is_a? String
    return display_time(field) + "\n" if field.is_a? Integer
    if field.is_a? Array
      field.each { |sub| display_text += display_field(sub) + "\n" }
    else
      field.each do |key, subfield|
        display_text += display_field(subfield) + ' ' if SUBFIELDS.include? key
      end
      field['codes']&.each do |code_system, code|
        display_text += "\n" + code_system + ': ' + code.join(', ')
      end
      display_text += "\n" + field['code_system'] + ': ' + field['code'] if field['code_system']
    end
    display_text
  end

  def coverage_for_measure(measure)
    query_cache_first = QueryCache.where(measure_id: measure.measure_id, sub_id: measure.sub_id, bundle_id: measure.bundle_id, test_id: nil).first
    query_cache_first ? query_cache_first['bonnie_coverage'] : nil
  end

  def hide_patient_calculation?
    # Hide measure calculation if Cypress is in ATL Mode and the current user is not an ATL or admin
    Settings.current.mode_atl? && (!current_user.user_role?('admin') && !current_user.user_role?('atl'))
  end

  def population_label(bundle, pop)
    bundle.modified_population_labels && bundle.modified_population_labels[pop] ? bundle.modified_population_labels[pop] : pop
  end
end
