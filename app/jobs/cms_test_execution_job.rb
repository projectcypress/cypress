# frozen_string_literal: true

class CmsTestExecutionJob < ApplicationJob
  include Job::Status
  queue_as :default

  PATIENTS_PER_CALCUATION = 200

  after_enqueue do |job|
    job.tracker.add_options(test_execution_id: job.arguments[0].id,
                            task_id: job.arguments[1].id)
  end
  def perform(test_execution, task, options = {})
    test_execution.state = :running
    test_execution.validate_artifact(task.validators, test_execution.artifact, options.merge('test_execution' => test_execution, 'task' => task))
    if test_execution.task.product_test.reporting_program_type == 'eh'
      precalc_state = test_execution.state
      test_execution.state = :calculating
      test_execution.save
      calculate_patients(test_execution)
      unless Patient.where(correlation_id: test_execution.id).exists?
        msg = 'No QRDA files found. Make sure files are not in a nested folder.'
        test_execution.execution_errors.build(message: msg, msg_type: :warning,
                                              validator: 'Validators::ProgramCriteriaValidator')
      end
      validate_measures(test_execution)
      test_execution.state = precalc_state
    end
    test_execution.save
  end

  def calculate_patients(test_execution)
    patients = Patient.where(correlation_id: test_execution.id)
    patient_ids = patients.map { |p| p.id.to_s }
    effective_date = Time.at(test_execution.task.product_test.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { effectiveDate: effective_date }
    eligible_measures, ineligible_measures = telehealth_eligible_and_ineligible_ecqms(test_execution.task.product_test.measures)
    total = (patient_ids.size / PATIENTS_PER_CALCUATION.to_f).ceil * test_execution.task.product_test.measures.size
    complete = 0
    calculate_patients_for_measures(patient_ids, options, eligible_measures, test_execution, total, complete) unless eligible_measures.empty?
    return if ineligible_measures.empty?

    address_telehealth_codes_in_patients(patients, ineligible_measures, test_execution)
    calculate_patients_for_measures(patient_ids, options, ineligible_measures, test_execution, total, complete)
  end

  def validate_measures(test_execution)
    measure_id_hash = test_execution.task.bundle.measures.only(:id, :hqmf_id).to_h { |m| [m.hqmf_id, m.id.to_s] }
    patients = Patient.where(correlation_id: test_execution.id)
    patients.each do |patient|
      reported_measure_ids = patient.reported_measure_hqmf_ids.map { |h| measure_id_hash[h] }
      missing_ids = patient.measure_relevance_hash.keys - reported_measure_ids
      missing_ids.each do |missing_measure|
        msg = "Document does not state it is reporting measure #{Measure.find(missing_measure).cms_id}"
        test_execution.execution_errors.build(message: msg, msg_type: :warning,
                                              validator: 'Validators::ProgramCriteriaValidator', file_name: patient.file_name)
      end
    end
  end

  def address_telehealth_codes_in_patients(patients, ineligible_measures, test_execution)
    # measures in the 2022 bundle and beyond include logic to exclude telehealth encounters
    return unless test_execution.task.bundle.major_version.to_i < 2022

    patients.each do |patient|
      warnings = patient.remove_telehealth_codes(ineligible_measures)
      warnings.each do |e|
        test_execution.execution_errors.build(message: e.message, msg_type: :warning, location: e.location, file_name: patient.file_name,
                                              validator_type: :result_validation, validator: 'Validators::ProgramCriteriaValidator')
      end
    end
  end

  def calculate_patients_for_measures(patient_ids, options, measures, test_execution, total_slices, slices_complete)
    tracker = test_execution.tracker
    patient_ids.each_slice(PATIENTS_PER_CALCUATION) do |patient_ids_slice|
      measures.each do |measure|
        SingleMeasureCalculationJob.perform_now(patient_ids_slice, measure.id.to_s, test_execution.id.to_s, options)
        slices_complete += 1
        tracker&.log("#{((slices_complete.to_f / total_slices) * 100).to_i}% of calculations complete")
      end
    end
  end

  def telehealth_eligible_and_ineligible_ecqms(measures)
    ineligible_measures = measures.where(:hqmf_id.in => APP_CONSTANTS['telehealth_ineligible_measures'])
    eligible_measures = measures.where(:hqmf_id.nin => APP_CONSTANTS['telehealth_ineligible_measures'])
    [eligible_measures, ineligible_measures]
  end
end
