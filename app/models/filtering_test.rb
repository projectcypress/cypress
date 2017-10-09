class FilteringTest < ProductTest
  field :options, type: Hash
  field :incl_addr, type: Boolean
  field :display_name, type: String
  accepts_nested_attributes_for :tasks

  after_create :create_tasks

  def create_tasks
    tasks.build({ product_test: self }, Cat1FilterTask).save
    tasks.build({ product_test: self }, Cat3FilterTask).save
    save
  end

  def cat1_task
    cat1_tasks = tasks.select { |task| task.is_a? Cat1FilterTask }
    if cat1_tasks.empty?
      false
    else
      cat1_tasks.first
    end
  end

  def cat3_task
    cat3_tasks = tasks.select { |task| task.is_a? Cat3FilterTask }
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
    prng = Random.new(rand_seed.to_i)
    random_mrn = ''
    while random_mrn[8] != '-'
      random_mrn = master_patient_ids.sample(random: prng)
    end
    rand_record = records.find_by(original_medical_record_number: random_mrn)
    # iterate over the filters and assign random codes
    params = { measures: measures, records: records, incl_addr: incl_addr, effective_date: created_at, prng: prng }
    options['filters'].each do |k, _v|
      options['filters'][k] = Cypress::CriteriaPicker.send(k, rand_record, params)
    end

    save!
  end

  def name_slug
    return options['filters'].keys.join('_') if display_name == ''

    display_name.gsub(/[^0-9A-Za-z.\-]+/, '_').downcase
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
      filters['patients'] = Cypress::RecordFilter.filter(records, input_filters, effective_date: created_at,
                                                                                 bundle_id: measures.first.bundle_id).pluck(:_id)
    end

    filters
  end

  def filtered_records
    Cypress::RecordFilter.filter(records, options['filters'], effective_date: created_at, bundle_id: measures.first.bundle_id)
  end
end
