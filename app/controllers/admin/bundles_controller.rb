module Admin
  class BundlesController < AdminController
    respond_to :html

    before_action :find_bundle, only: [:set_default, :deprecate, :destroy]

    add_breadcrumb 'Add Bundle', :new_admin_bundle_path, only: [:new]

    def index
      redirect_to admin_path(anchor: 'bundles')
    end

    def new
      @bundle = Bundle.new
    end

    def set_default
      @bundle.update_default
      redirect_to admin_path(anchor: 'bundles')
    end

    def create
      # save file to a temporary location
      if params['file']
        unless File.extname(params['file'].original_filename) == '.zip'
          flash[:alert] = 'Bundle file must have extension .zip'
          redirect_to new_admin_bundle_path
          return
        end

        bundle_file = params['file']
        FileUtils.mkdir_p(APP_CONSTANTS['bundle_file_path'])
        file_name = generate_file_path
        file_path = File.join(APP_CONSTANTS['bundle_file_path'], file_name)
        FileUtils.mv(temp_file_path, file_path)
        BundleUploadJob.perform_later(file_path, bundle_file.original_filename)
        redirect_to admin_path(anchor: 'bundles')
      else
        flash[:alert] = 'No bundle file provided.'
        redirect_to new_admin_bundle_path
      end
    end

    def deprecate
      bundle_title = @bundle.title
      @bundle.deprecate

      # clear this cache just in case it's pointing to the bundle just deprecated
      Rails.cache.delete('any_installed_bundle')
      flash_comment(bundle_title, 'danger', 'depreceated')
      redirect_to admin_path(anchor: 'bundles')
    end

    def destroy
      bundle_title = @bundle.title
      @bundle.destroy

      # clear this cache just in case it's pointing to the bundle just deleted
      Rails.cache.delete('any_installed_bundle')
      flash_comment(bundle_title, 'danger', 'deleted')
      redirect_to admin_path(anchor: 'bundles')
    end

    def find_bundle
      @bundle = Bundle.find(params['id'])
    end

    private

    def temp_file_path
      params['file'].tempfile.path
    end

    def generate_file_path
      "bundle_#{rand(Time.now.to_i)}.zip"
    end
  end
end
