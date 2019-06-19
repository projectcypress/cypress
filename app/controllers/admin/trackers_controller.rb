module Admin
  class TrackersController < AdminController
    before_action :find_tracker

    def destroy
      @tracker.destroy if @tracker.status == :failed
      redirect_to admin_path(anchor: 'bundles') if @tracker[:job_class] == 'BundleUploadJob'
      redirect_to vendor_records_path(@tracker[:options]['vendor_id']) if @tracker[:job_class] == 'VendorPatientUploadJob'
    end

    private

    def find_tracker
      @tracker = Tracker.find(params['id'])
    end
  end
end
