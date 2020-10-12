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

  def perform(file, _original_filename, vendor_id, bundle_id)
    tracker.log('Importing')

    vendor_patient_file = File.new(file)

    bundle = Bundle.find(bundle_id)
    patients, failed_files = parse_patients(vendor_patient_file, vendor_id, bundle)

    # do patient calculation against bundle
    unless patients.empty?
      generate_calculations(patients, bundle, vendor_id)
      PatientAnalysisJob.perform_later(bundle.id.to_s, vendor_id)
    end

    raise failed_files.to_s unless failed_files.empty?
  end

  def parse_patients(file, vendor_id, bundle)
    artifact = Artifact.new(file: file)
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

    [patients, failed_files]
  end

  # Take xml file name, data, error collection hash, return CQM::Patient
  def add_patient(data, validator, vendor_id, bundle)
    doc = Nokogiri::XML::Document.parse(data)
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
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
    unless doc_start
      return false, 'Document needs to report the Measurement Start Date'
      # doc_end = validator.measure_period_end(doc).value -> should we validate end???
    end

    # import
    begin
      patient, _warnings = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)

      # shift date
      utc_start = DateTime.parse(doc_start).to_time.utc
      bundle_utc_start = DateTime.strptime(bundle.measure_period_start.to_s, '%s').utc
      # Compare date alone, without time
      if utc_start.strftime('%x') != bundle_utc_start.strftime('%x')
        time_dif = bundle.measure_period_start - utc_start.to_i
        patient.qdmPatient.shift_dates(time_dif)
      end

      patient.update(_type: CQM::VendorPatient, correlation_id: vendor_id, bundleId: bundle.id)
      Cypress::QRDAPostProcessor.replace_negated_codes(patient, bundle)
      patient.save
      return [true, patient]
    rescue => e
      return [false, e.to_s]
    end
  end

  def generate_calculations(patients, bundle, vendor_id)
    patient_ids = patients.map { |p| p.id.to_s }
    options = { 'effectiveDateEnd' => Time.at(bundle.effective_date).in_time_zone.to_formatted_s(:number),
                'effectiveDate' => Time.at(bundle.measure_period_start).in_time_zone.to_formatted_s(:number),
                'includeClauseResults' => true }
    tracker_index = 0
    # cqm-execution-service (using includeClauseResults) can run out of memory when it is run with a lot of patients.
    # 20 patients was selected after monitoring performance when experimenting with varying counts (from 1 to 100)
    # with all of the measures
    patients_per_calculation = 20
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
