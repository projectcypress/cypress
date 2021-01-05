class CMSTestExecutionJob < ApplicationJob
  include Job::Status
  queue_as :default

  after_enqueue do |job|
    job.tracker.add_options(test_execution_id: job.arguments[0].id,
                            task_id: job.arguments[1].id)
  end
  def perform(te, task, options = {})
    te.state = :running
    te.validate_artifact(task.validators, te.artifact, options.merge('test_execution' => te, 'task' => task))
    if te.task.product_test.reporting_program_type == 'eh'
      precalc_state = te.state
      te.state = :calculating
      te.save
      calculate_patients(te)
      te.state = validate_measures(te) ? precalc_state : :failed
    end
    te.save
  end

  def calculate_patients(test_execution)
    patients = Patient.where(correlation_id: test_execution.id)
    patient_ids = patients.map { |p| p.id.to_s }
    effective_date = Time.at(test_execution.task.product_test.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { 'effectiveDate': effective_date }
    eligible_measures, ineligible_measures = telehealth_eligible_and_ineligible_ecqms(test_execution.task.product_test.measures)
    calculate_patients_for_measures(patient_ids, options, eligible_measures, test_execution) unless eligible_measures.empty?
    unless ineligible_measures.empty?
      address_telehealth_codes_in_patients(patients, ineligible_measures, test_execution)
      calculate_patients_for_measures(patient_ids, options, ineligible_measures, test_execution)
    end
  end

  def validate_measures(test_execution)
    has_missing_ids = false
    measure_id_hash = test_execution.task.bundle.measures.only(:id, :hqmf_id).to_h { |m| [m.hqmf_id, m.id.to_s] }
    patients = Patient.where(correlation_id: test_execution.id)
    patients.each do |patient|
      reported_measure_ids = patient.reported_measure_hqmf_ids.map { |h| measure_id_hash[h] }
      missing_ids = patient.measure_relevance_hash.keys - reported_measure_ids
      missing_ids.each do |missing_measure|
        has_missing_ids = true
        msg = "Document does not state it is reporting measure #{Measure.find(missing_measure).cms_id}"
        test_execution.execution_errors.build(message: msg, msg_type: :error, validator: :qrda_cat1, file_name: patient.file_name)
      end
    end
    has_missing_ids ? false : true
  end

  def address_telehealth_codes_in_patients(patients, ineligible_measures, test_execution)
    patients.each do |patient|
      warnings = patient.remove_telehealth_codes(ineligible_measures)
      warnings.each do |e|
        test_execution.execution_errors.build(message: e.message, msg_type: :warning, location: e.location, file_name: patient.file_name,
                                              validator_type: :result_validation, validator: 'Validators::ProgramCriteriaValidator')
      end
    end
  end

  def calculate_patients_for_measures(patient_ids, options, measures, test_execution)
    patients_per_calculation = 200
    patient_ids.each_slice(patients_per_calculation) do |patient_ids_slice|
      measures.each do |measure|
        SingleMeasureCalculationJob.perform_now(patient_ids_slice, measure.id.to_s, test_execution.id.to_s, options)
      end
    end
  end

  def telehealth_eligible_and_ineligible_ecqms(measures)
    ineligible_measures = measures.where(:hqmf_id.in => APP_CONSTANTS['telehealth_ineligible_measures'])
    eligible_measures = measures.where(:hqmf_id.nin => APP_CONSTANTS['telehealth_ineligible_measures'])
    [eligible_measures, ineligible_measures]
  end
end
