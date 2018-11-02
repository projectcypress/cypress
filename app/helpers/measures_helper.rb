module MeasuresHelper
  def pick_measure_for_filtering_test(available_measures, bundle)
    bundle.measures.top_level.find_by(hqmf_id: pick_measure_id_for_filtering_test(available_measures, bundle))
  end

  # Pick a measure from the choices for the C4 filtering tests.
  # Chooses a random measure in this order:
  # 1) CPC Measures with Diagnosis Criteria
  # 2) CPC Measures
  # 3) Measures with Diagnosis Criteria
  # 4) Random Measure
  def pick_measure_id_for_filtering_test(available_measures, bundle)
    # TODO: CQL: change how criteria is accessed based on new measure model
    cpc_msrs = available_measures & APP_CONSTANTS['CPC_measures'].values.flatten

    # this seems slow but there doesn't seem to be any way to do it purely with mongo
    with_diag = bundle.measures.in(hqmf_id: available_measures).select { |m| measure_has_diagnosis_criteria?(m) }.collect!(&:hqmf_id)

    cpc_and_diag = cpc_msrs & with_diag
    # not all cpc measures have a diagnosis, for example CMS 138

    return cpc_and_diag.sample if cpc_and_diag.count.positive?
    return cpc_msrs.sample if cpc_msrs.count.positive?
    return with_diag.sample if with_diag.count.positive?

    available_measures.sample
  end

  def measure_has_diagnosis_criteria?(measure)
    # TODO: CQL: change measure model
    return false unless measure['source_data_criteria']

    measure['source_data_criteria'].values.any? { |criteria| criteria['definition'] == 'diagnosis' }
  end

  # used in _measure_tests_table.html.erb view
  # returns true if measure test is not ready (not built yet) or if measure test has a test execution that is running
  def should_reload_measure_test?(test)
    return true if test.state != :ready

    test.tasks.each do |task|
      task.test_executions.each do |execution|
        return true if execution.state == :pending
      end
    end
    false
  end

  def type_counts(measures)
    h = measures.map(&:type).each_with_object(Hash.new(0)) { |type, count| count[type.upcase] += 1 } # example { "EH"=> 4, "EP" => 2 }
    h.map { |k, v| "#{v} #{k}" }.join(', ') # 4 EH, 2 EP
  end

  # Format the category (type count) as it is actually shown on the measure tabs
  def formatted_type_counts(category, measures)
    "#{category} (#{type_counts(measures)})"
  end

  def get_div_name(value)
    "#{value.tr(" '", '_')}_div"
  end
end
