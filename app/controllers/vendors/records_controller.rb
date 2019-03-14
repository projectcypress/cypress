module Vendors
  class RecordsController < ::RecordsController
    include ::CqmValidators

    before_action :set_vendor, :authorize_vendor, :set_record_source

    def new
      add_breadcrumb 'Add Patient', :new_admin_bundle_path, only: [:new]
    end

    # create patients for vendor
    def create
      # check for zip file
      if params['file'] && File.extname(params['file'].original_filename) == '.zip'
        artifact = Artifact.new(file: params['file'])
        failed_files = {} # hash (filename -> error array)
        patients = []
        artifact.each do |name, data|
          patient = add_patient(name, data, failed_files)
          patients << patient unless patient.nil?
        rescue => e
          failed_files[name] = ['Unable to import file as patient.']
          Rails.logger.error "Patient import for vendor #{params[:vendor_id]} failed: #{e}"
        end
        assemble_alert(failed_files)

        # do patient calculation against bundle
        generate_calculations patients
        flash[:notice] = "Imported #{patients.count} #{'patient'.pluralize(patients.count)}"
        # redirect to get (show) records for vendor
        redirect_to vendor_records_path(vendor_id: params[:vendor_id])
      else
        redirect_back(fallback_location: new_vendor_record_path, alert: 'No valid patient file provided. Uploaded file must have extension .zip')
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
    def add_patient(name, data, failed_files)
      doc = Nokogiri::XML::Document.parse(data)
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')

      # basic CDA schema validation
      validator = CDA.instance
      errors = validator.validate(doc)
      unless errors.empty?
        failed_files[name] = errors.map(&:message)
        return nil
      end

      # import
      patient = QRDA::Cat1::PatientImporter.instance.parse_cat1(doc)
      patient.update(_type: CQM::VendorPatient, correlation_id: params[:vendor_id])
      patient
    end

    def generate_calculations(patients)
      calc_job = Cypress::CqmExecutionCalc.new(patients.map(&:qdmPatient), @bundle.measures, params[:vendor_id],
                                               'effectiveDateEnd': Time.at(@bundle.effective_date).in_time_zone.to_formatted_s(:number),
                                               'effectiveDate': Time.at(@bundle.measure_period_start).in_time_zone.to_formatted_s(:number))
      calc_job.execute
    end

    def authorize_vendor
      authorize_request(@vendor)
    end
  end
end
