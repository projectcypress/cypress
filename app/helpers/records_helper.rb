module RecordsHelper
  SECTIONS = %w(allergies care_goals conditions encounters immunizations
                medical_equipment medications procedures results communications
                family_history social_history vital_signs support advance_directives
                insurance_providers functional_statuses).freeze

  CV_POPULATION_KEYS = %w(IPP MSRPOPL MSRPOPLEX OBSERV).freeze
  PROPORTION_POPULATION_KEYS = %w(IPP DENOM NUMER DENEX DENEXCEP).freeze

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

  def full_name(record)
    record.first + ' ' + record.last if record
  end

  def get_result_value(results, measure, population)
    result_value = results.where('value.measure_id' => measure.hqmf_id).where('value.sub_id' => measure.sub_id)
    result_value.first.value[population].to_i if result_value.first
  end

  def records_by_measure(records, measure)
    # Returns array of records that have at least one calculation result for the given measure id

    records.select { |r| r.calculation_results.where('value.measure_id' => measure.hqmf_id).where('value.sub_id' => measure.sub_id).length > 0 }
  end
end
