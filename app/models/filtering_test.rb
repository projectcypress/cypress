# frozen_string_literal: true

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
    rescue StandardError
      return 'incomplete'
    end
    task.status
  end

  def pick_filter_criteria
    return unless options && options['filters']

    # select a random patient
    prng = Random.new(rand_seed.to_i)

    measure_object_ids = measures.pluck(:_id)
    rand_patient = patients.select { |p| p.patient_relevant?(measure_object_ids, ['IPP']) }.sample
    # iterate over the filters and assign random codes
    params = { measures:, patients:, incl_addr:, effective_date: created_at, prng: }
    options['filters'].each_key do |k|
      # NOTE: typically just uses criteria from one random patient, not across several patients
      options['filters'][k] = Cypress::CriteriaPicker.send(k, rand_patient, params)
    end
    save!
  end

  def name_slug
    return options['filters'].keys.join('_') if display_name == ''

    display_name.gsub(/[^0-9A-Za-z.-]+/, '_').downcase
  end

  def filtered_patients
    Cypress::PatientFilter.filter(patients, options['filters'], effective_date: created_at, bundle_id: measures.first.bundle_id)
  end
end
