module MeasuresHelper
  def pick_measure_for_filtering_test(available_measures)
    Measure.top_level.find_by(hqmf_id: pick_measure_id_for_filtering_test(available_measures))
  end

  # Pick a measure from the choices for the C4 filtering tests.
  # Chooses a random measure in this order:
  # 1) CPC Measures with Diagnosis Criteria
  # 2) CPC Measures
  # 3) Measures with Diagnosis Criteria
  # 4) Random Measure
  def pick_measure_id_for_filtering_test(available_measures)
    cpc_msrs = available_measures & APP_CONFIG['CPC_measures'].values.flatten

    # this seems slow but there doesn't seem to be any way to do it purely with mongo
    with_diag = Measure.in(hqmf_id: available_measures).select { |m| measure_has_diagnosis_criteria?(m) }.collect!(&:hqmf_id)

    cpc_and_diag = cpc_msrs & with_diag
    # not all cpc measures have a diagnosis, for example CMS 138

    return cpc_and_diag.sample if cpc_and_diag.count > 0
    return cpc_msrs.sample if cpc_msrs.count > 0
    return with_diag.sample if with_diag.count > 0

    available_measures.sample
  end

  def measure_has_diagnosis_criteria?(measure)
    return false unless measure && measure.hqmf_document && measure.hqmf_document['source_data_criteria']
    measure.hqmf_document['source_data_criteria'].values.any? { |criteria| criteria['definition'] == 'diagnosis' }
  end
end
