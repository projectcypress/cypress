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
        options['filters']['providers'] = rand_record.lookup_provider(incl_addr)
      when 'problems'
        problem_oid = lookup_problem
        options['filters']['problems'] = { oid: [problem_oid], hqmf_ids: hqmf_oids_for_problem(problem_oid) }
      end
    end
    save!
  end

  def lookup_problem
    measure = measures.first
    code_list_id = fallback_id = ''
    # determine which data criteira are diagnoses, and make sure we choose one that one of our records has
    # if we can't find one that matches a record, just use any diagnosis
    measure.hqmf_document.source_data_criteria.each do |_criteria, criteria_hash|
      next unless criteria_hash.definition.eql? 'diagnosis'
      fallback_id = criteria_hash.code_list_id
      hqmf_oid = HQMF::DataCriteria.template_id_for_definition(criteria_hash.definition, criteria_hash.status, criteria_hash.negation)
      if Cypress::RecordFilter.filter(records, { 'problems' => { oid: [criteria_hash.code_list_id], hqmf_ids: [hqmf_oid] } }, {}).count > 0
        code_list_id = criteria_hash.code_list_id
        break
      end
    end

    code_list_id.empty? ? fallback_id : code_list_id
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

  def hqmf_oids_for_problem(problem_oid)
    measure = measures.first
    hqmf_oids = []
    measure.hqmf_document.source_data_criteria.each do |_criteria, criteria_hash|
      next unless criteria_hash.key?('code_list_id') && criteria_hash.code_list_id == problem_oid
      hqmf_oids << HQMF::DataCriteria.template_id_for_definition(criteria_hash.definition, criteria_hash.status, criteria_hash.negation)
    end
    hqmf_oids.uniq
  end

  def filtered_records
    Cypress::RecordFilter.filter(records, options['filters'], effective_date: effective_date)
  end
end
