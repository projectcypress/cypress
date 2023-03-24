# frozen_string_literal: true

class VendorPatientUploadJob < ApplicationJob
  include Job::Status
  include ::CqmValidators
  include ::Validators

  after_enqueue do |job|
    tracker = job.tracker
    tracker.options['original_filename'] = job.arguments[1]
    tracker.options['vendor_id'] = job.arguments[2]
    tracker.save
  end

  def perform(file, _original_filename, vendor_id, bundle_id, include_highlighting)
    tracker.log('Importing')

    vendor_patient_file = File.new(file)

    bundle = Bundle.find(bundle_id)
    if bundle.categorized_codes.empty?
      bundle.collect_codes_by_qdm_category
      bundle.save
    end
    patients, failed_files = parse_patients(vendor_patient_file, vendor_id, bundle)

    # do patient calculation against bundle
    unless patients.empty?
      generate_calculations(patients, bundle, vendor_id, include_highlighting)
      PatientAnalysisJob.perform_later(bundle.id.to_s, vendor_id)
    end
    File.delete(file)
    raise failed_files.to_s unless failed_files.empty?
  end

  def parse_patients(file, vendor_id, bundle)
    artifact = Artifact.new(file:)
    failed_files = {} # hash (filename -> error array)
    patients = []
    validator = CDA.instance

    artifact.each do |name, data|
      # Add a patient if it passes CDA validation
      valid, patient_or_errors = add_patient(data, validator, vendor_id, bundle)
      if valid
        patients << patient_or_errors unless patient_or_errors.nil?
      else
        failed_files[name] = patient_or_errors
      end
    end
    # Remove the file that is store when creating the artifact. We also want to remove the folder
    FileUtils.rm_rf(File.dirname(artifact.file.path))

    failed_files['zip'] = 'No QRDA files found. Make sure files are not in a nested folder.' if patients.empty? && failed_files.empty?
    [patients, failed_files]
  end

  # Take xml file name, data, error collection hash, return CQM::Patient
  def add_patient(data, validator, vendor_id, bundle)
    doc = Nokogiri::XML::Document.parse(data)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

    # basic CDA schema validation
    errors = validator.validate(doc)
    return [false, errors.map(&:message)] unless errors.empty?

    time_shifted_patient(doc, vendor_id, bundle)
  end

  def time_shifted_patient(doc, vendor_id, bundle)
    # check for start date
    year_validator = MeasurePeriodValidator.new
    doc_start = year_validator.measure_period_start(doc)&.value
    # doc_end = validator.measure_period_end(doc).value -> should we validate end???
    return false, 'Document needs to report the Measurement Start Date' unless doc_start

    # import
    begin
      patient, _warnings, codes = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)

      # use all patient codes to build description map
      Cypress::QrdaPostProcessor.build_code_descriptions(codes, patient, bundle)

      # shift date
      utc_start = DateTime.parse(doc_start).to_time.utc
      # Compare date alone, without time
      if utc_start.strftime('%x') != DateTime.strptime(bundle.measure_period_start.to_s, '%s').utc.strftime('%x')
        time_dif = bundle.measure_period_start - utc_start.to_i
        patient.qdmPatient.shift_dates(time_dif)
      end

      patient.update(_type: CQM::VendorPatient, correlation_id: vendor_id, bundleId: bundle.id)
      Cypress::QrdaPostProcessor.replace_negated_codes(patient, bundle)
      Cypress::QrdaPostProcessor.remove_unmatched_data_type_code_combinations(patient, bundle)
      Cypress::QrdaPostProcessor.remove_invalid_qdm_56_data_types(patient) if bundle.major_version.to_i > 2021
      patient.save
      [true, patient]
    rescue StandardError => e
      [false, e.to_s]
    end
  end

  def generate_calculations(patients, bundle, vendor_id, include_highlighting)
    patient_ids = patients.map { |p| p.id.to_s }
    options = { effectiveDate: Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number),
                includeClauseResults: include_highlighting }
    tracker_index = 0
    # cqm-execution-service (using includeClauseResults) can run out of memory when it is run with a lot of patients.
    # 20 patients was selected after monitoring performance when experimenting with varying counts (from 1 to 100)
    # with all of the measures
    patients_per_calculation = include_highlighting ? 20 : 200
    # Total count is the number of patient slices - (total patients / patients_per_calculation) + 1
    # multiplied by the total number of measures.
    # For example, and upload of 115 patients for 5 measures would be 6 patient slices (101 / 20) + 1 = 6
    # multiplied by 5 measures for a total of 30.
    total_count = ((patient_ids.size / patients_per_calculation) + 1) * bundle.measures.size
    patient_ids.each_slice(patients_per_calculation) do |patient_ids_slice|
      bundle.measures.each do |measure|
        tracker.log("Calculating (#{((tracker_index.to_f / total_count) * 100).to_i}% complete) ")
        SingleMeasureCalculationJob.perform_now(patient_ids_slice, measure.id.to_s, vendor_id, options)
        tracker_index += 1
      end
    end
  end
end
