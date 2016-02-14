class FilteringTest < ProductTest
  field :options, type: Hash
  accepts_nested_attributes_for :tasks

  after_create :create_tasks

  def create_tasks
    tasks.build({ product_test: self }, Cat1FilterTask).save
    tasks.build({ product_test: self }, Cat3FilterTask).save
    save
  end

  def cat1_task
    cat1_tasks = tasks.select { |task| task._type == 'Cat1FilterTask' }
    if cat1_tasks.empty?
      false
    else
      cat1_tasks.first
    end
  end

  def cat3_task
    cat3_tasks = tasks.select { |task| task._type == 'Cat3FilterTask' }
    if cat3_tasks.empty?
      false
    else
      cat3_tasks.first
    end
  end

  def task_status(task_type)
    begin
      task = tasks.find_by(_type: task_type)
    rescue
      return 'incomplete'
    end
    task.status
  end

  def pick_filter_criteria
    return unless options && options['filters']
    # select a random patient
    rand_record = records.sample
    # iterate over the filters and assign random codes
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
      when 'providers'
        options['filters']['providers'] = lookup_provider(rand_record)
      when 'problems'
        v << lookup_problem
      end
    end
    save!
  end

  def lookup_provider(record)
    provider = Provider.find(record.provider_performances.first['provider_id'])
    addresses = []
    provider.addresses.each do |address|
      addresses << { 'street' => address.street, 'city' => address.city, 'state' => address.state, 'zip' => address.zip,
                     'country' => address.country }
    end
    { 'npis' => [provider.npi], 'tins' => [provider.tin], 'addresses' => addresses }
  end

  def lookup_problem
    measure = Measure.find_by(hqmf_id: measure_ids.first)
    code_list_id = fallback_id = ''
    # determine which data criteira are diagnoses, and make sure we choose one that one of our records has
    # if we can't find one that matches a record, just use any diagnosis
    measure.hqmf_document.source_data_criteria.each do |_criteria, criteria_hash|
      next unless criteria_hash.definition.eql? 'diagnosis'
      fallback_id = criteria_hash.code_list_id
      if Cypress::RecordFilter.filter(records, { 'problems' => [criteria_hash.code_list_id] }, {}).count > 0
        code_list_id = criteria_hash.code_list_id
        break
      end
    end

    if code_list_id.empty?
      fallback_id
    else
      code_list_id
    end
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
      filters['patients'] = Cypress::RecordFilter.filter(records, input_filters, effective_date: effective_date).pluck(:_id)
    end

    filters
  end

  def filtered_records
    Cypress::RecordFilter.filter(records, options['filters'], effective_date: effective_date)
  end
end
