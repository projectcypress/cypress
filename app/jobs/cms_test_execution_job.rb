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
    precalc_state = te.state
    te.state = :calculating
    te.save
    calculate_patients(te) if te.task.product_test.reporting_program_type == 'eh'
    te.state = precalc_state
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
    patients_per_calculation = 500
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
