class FilteringTest < ProductTest
  field :options, type: Hash
  accepts_nested_attributes_for :tasks

  def pick_filter_criteria
    return unless options && options['filters']
    # select a random patient
    rand_record = records.sample
    # loop through the filters and assign random codes
    # as of now there will only be one filter per Test, but leaving this as a list in case that changes
    options['filters'].each do |k, v|
      next if v.count > 0
      case k
      when 'races'
        v << rand_record.race['code']
      when 'ethnicities'
        v << rand_record.ethnicity['code']
      when 'genders'
        v << rand_record.gender
      when 'payers'
        v << rand_record.insurance_providers.first.name
      end
    end
    save! # is this necessary?
  end

  # Final Rule defines 9 different criteria that can be filtered:
  #
  # (A) TIN .................... (F) Age
  # (B) NPI .................... (G) Sex
  # (C) Provider Type .......... (H) Race + Ethnicity
  # (D) Practice Site Address .. (I) Problem
  # (E) Patient Insurance
  #
  def patient_cache_filter
    input_filters = (options['filters'] || {}).dup
    filters = {}
    # QME can handle races, ethnicities, genders, providers, and patient_ids (and languages)
    # so pass these through directly

    filters['races'] = input_filters.delete 'races' if input_filters['races']
    filters['ethnicities'] = input_filters.delete 'ethnicities' if input_filters['ethnicities']
    filters['genders'] = input_filters.delete 'genders' if input_filters['genders']

    if input_filters['providers']
      providers = Cypress::ProviderFilter.filter(Provider.all, input_filters['providers'], options)
      filters['providers'] = providers.pluck(:_id)
      input_filters.delete 'providers'
    end

    # for the rest, manually filter to get the record IDs and pass those in
    if input_filters.count > 0
      filters['patients'] = Cypress::RecordFilter.filter(product_test.records, input_filters, effective_date: product_test.effective_date).pluck(:_id)
    end

    filters
  end

  def filtered_records
    Cypress::RecordFilter.filter(product_test.records, input_filters, effective_date: product_test.effective_date)
  end
end
