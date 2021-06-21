# frozen_string_literal: true

module Vendors
  class RecordsController < ::RecordsController
    include PatientAnalysisHelper

    before_action :set_vendor, :authorize_vendor, :set_record_source

    def new
      @default = Bundle.find(params['default'])
      add_breadcrumb 'Add Patient', :new_admin_bundle_path, only: [:new]
    end

    # create patients for vendor
    def create
      # save file to a temporary location
      if params['file']
        FileUtils.mkdir_p(APP_CONSTANTS['vendor_file_path'])
        file_name = generate_file_path
        file_path = File.join(APP_CONSTANTS['vendor_file_path'], file_name)
        FileUtils.mv(temp_file_path, file_path)
        VendorPatientUploadJob.perform_later(file_path, params['file'].original_filename, params[:vendor_id], @bundle.id.to_s)
        redirect_to vendor_records_path(vendor_id: params[:vendor_id], bundle_id: @bundle.id)
      else
        flash[:alert] = 'No vendor patient file provided.'
        redirect_back(fallback_location: { action: 'new', default: @bundle.id })
      end
    end

    # Destroy selected vendor patients
    def destroy_multiple
      # Remove selected patients from database
      id_list = params[:patient_ids].split(',')
      number_deleted = Patient.where(id: { '$in': id_list }).destroy_all
      redirect_back(fallback_location: root_path)
      # If something can't be deleted, we want to flash that as well as anything that was deleted.
      if number_deleted == id_list.length
        flash[:notice] = "Deleted #{number_deleted} #{'patient'.pluralize(number_deleted)}."
      else
        difference = id_list.length - number_deleted
        flash[:notice] = "#{difference} #{'patient'.pluralize(difference)} could not be deleted. \
          Deleted #{number_deleted} #{'patient'.pluralize(number_deleted)}."
      end
    end

    def patient_analysis
      @analysis = @vendor.vendor_patient_analysis[@bundle.id.to_s]
      add_breadcrumb 'Analysis', :patient_analysis_vendor_records_path
    end

    private

    def temp_file_path
      params['file'].tempfile.path
    end

    def generate_file_path
      "vp_#{rand(Time.now.to_i)}.zip"
    end

    def authorize_vendor
      authorize_request(@vendor, read: %w[show index by_measure], manage: %w[new create update destroy delete edit])
    end
  end
end
