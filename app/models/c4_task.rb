class C4Task < Task
  after_create :pick_filter_criteria
  def after_create
    # generate expected results here.  Will need to gen quailty report
    # for each of the measures in the product_test but constrainted to the
    # filter provided for test.  Filter data should live in the options field
    # that is defined in Task
    MeasureEvaluationJob.perform_now(self, 'filters' => patient_cache_filter)
  end

  # C4 = Filter
  #  - Record the required data elements
  #  - Filter CQM results at the patient and aggregate level
  #  - Export Cat 1 or Cat 3
  def validators
    # input file not used yet - for now just assume it's cat 3
    # at some point will need to check if it's cat 1
    @validators ||= [::Validators::QrdaCat3Validator.new(product_test.expected_results),
                     ::Validators::MeasurePeriodValidator.new,
                     ::Validators::ExpectedResultsValidator.new(product_test.expected_results)]
  end

  def execute(file)
    te = test_executions.create(expected_results: expected_results)
    te.artifact = Artifact.new(file: file)
    TestExecutionJob.perform_later(te, self)
    te.save
    te
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

  # this will fetch the records associted with the product test but constrained
  # according to the filters configured for the task
  def records
    Cypress::RecordFilter.filter(product_test.records, options['filters'], effective_date: product_test.effective_date)
  end

  def partial_name
    model_name.name.underscore
  end

  def pick_filter_criteria
    return unless options && options['filters']
    # select a random patient
    rand_record = product_test.records.sample
    # loop through the filters and assign random codes
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
end
