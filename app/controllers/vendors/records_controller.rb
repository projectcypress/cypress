module Vendors
  class RecordsController < ::RecordsController
    include ::CqmValidators
    include ::Validators

    before_action :set_vendor, :authorize_vendor, :set_record_source

    def new
      @default = Bundle.find(params['default'])
      add_breadcrumb 'Add Patient', :new_admin_bundle_path, only: [:new]
    end

    # create patients for vendor
    def create
      # check for zip file
      if params['file'] && File.extname(params['file'].original_filename) == '.zip'
        patients, failed_files, num_shifted = parse_patients

        assemble_alert(failed_files)

        # do patient calculation against bundle
        generate_calculations patients
        flash[:notice] = "Imported #{patients.count} #{'patient'.pluralize(patients.count)}, with #{num_shifted} date-shifted"
        # redirect to get (show) records for vendor
        redirect_to vendor_records_path(vendor_id: params[:vendor_id], bundle_id: @bundle.id)
      else
        redirect_back(fallback_location: { action: 'new', default: @bundle.id })
        flash[:alert] = 'No valid patient file provided. Uploaded file must have extension .zip'
      end
    end

    def parse_patients
      artifact = Artifact.new(file: params['file'])
      failed_files = {} # hash (filename -> error array)
      patients = []
      validator = CDA.instance
      num_shifted = 0
      artifact.each do |name, data|
        patient, time_dif = add_patient(name, data, failed_files, validator)
        num_shifted += 1 if time_dif != 0
        patients << patient unless patient.nil?
      rescue => e
        failed_files[name] = ['Unable to import file as patient.']
        Rails.logger.error "Patient import for vendor #{params[:vendor_id]} failed: #{e}"
      end

      [patients, failed_files, num_shifted]
    end

    # Destroy selected vendor patients
    def destroy_multiple
      # Remove selected patients from database
      id_list = params[:patient_ids].split(',')
      number_deleted = Patient.where(id: { '$in': id_list }).destroy_all
      redirect_back(fallback_location: root_path)
      # If something can't be deleted, we want to flash that as well as anything that was deleted.
      if number_deleted != id_list.length
        difference = id_list.length - number_deleted
        flash[:notice] = "#{difference} #{'patient'.pluralize(difference)} could not be deleted. \
          Deleted #{number_deleted} #{'patient'.pluralize(number_deleted)}."
      else
        flash[:notice] = "Deleted #{number_deleted} #{'patient'.pluralize(number_deleted)}."
      end
    end

    private

    def assemble_alert(failed_files)
      full_alert = ''
      failed_files.each do |file, error_messages|
        full_alert += "\'#{file}\' had errors: #{error_messages.join('; ')}\n"
      end
      flash[:alert] = full_alert unless full_alert.empty?
    end

    # Take xml file name, data, error collection hash, return CQM::Patient
    def add_patient(name, data, failed_files, validator)
      doc = Nokogiri::XML::Document.parse(data)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

      # basic CDA schema validation
      errors = validator.validate(doc)
      unless errors.empty?
        failed_files[name] = errors.map(&:message)
        return nil, 0
      end

      time_shifted_patient(doc)
    end

    def time_shifted_patient(doc)
      # check for start date
      year_validator = MeasurePeriodValidator.new
      doc_start = year_validator.measure_period_start(doc).value
      unless doc_start
        failed_files[name] = ['Document needs to report the Measurement Start Date']
        return nil, 0
        # doc_end = validator.measure_period_end(doc).value -> should we validate end???
      end

      # import
      patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
      patient.update(_type: CQM::VendorPatient, correlation_id: params[:vendor_id], bundleId: @bundle.id)

      # shift date
      utc_start = DateTime.parse(doc_start).to_time.utc
      bundle_utc_start = DateTime.strptime(@bundle.measure_period_start.to_s, '%s').utc
      time_dif = 0
      # Compare date alone, without time
      if utc_start.strftime('%x') != bundle_utc_start.strftime('%x')
        time_dif = @bundle.measure_period_start - utc_start.to_i
        patient.qdmPatient.shift_dates(time_dif)
      end

      patient.save
      [patient, time_dif]
    end

    def generate_calculations(patients)
      calc_job = Cypress::CqmExecutionCalc.new(patients.map(&:qdmPatient), @bundle.measures, params[:vendor_id],
                                               'effectiveDateEnd': Time.at(@bundle.effective_date).in_time_zone.to_formatted_s(:number),
                                               'effectiveDate': Time.at(@bundle.measure_period_start).in_time_zone.to_formatted_s(:number))
      calc_job.execute
    end

    def authorize_vendor
      authorize_request(@vendor, { read: %w[show index by_measure], manage: %w[new create update destroy delete edit] })
    end
  end
end
