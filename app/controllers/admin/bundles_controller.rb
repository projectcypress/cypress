module Admin
  class BundlesController < AdminController
    include CypressYaml
    respond_to :html

    before_action :find_bundle, only: [:set_default, :destroy]

    add_breadcrumb 'Admin', :admin_bundles_path
    add_breadcrumb 'Add Bundle', :new_admin_bundle_path, only: [:new]

    def index
      redirect_to admin_path(anchor: 'bundles')
    end

    def new
      @bundle = Bundle.new
    end

    def set_default
      Bundle.where(active: true).update_all(active: false)

      @bundle.active = true
      @bundle.save!
      Settings[:default_bundle] = @bundle.version
      sub_yml_setting('default_bundle', Settings[:default_bundle])
      redirect_to admin_path(anchor: 'bundles')
    end

    def create
      # save file to a temporary location
      bundle_file = params['file']
      FileUtils.mkdir_p(APP_CONFIG.bundle_file_path)
      file_name = generate_file_path
      file_path = File.join(APP_CONFIG.bundle_file_path, file_name)
      FileUtils.mv(temp_file_path, file_path)
      BundleUploadJob.perform_later(file_path, bundle_file.original_filename)
      redirect_to admin_path(anchor: 'bundles')
    end

    def destroy
      @bundle.destroy

      # clear this cache just in case it's pointing to the bundle just deleted
      Rails.cache.delete('any_installed_bundle')

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
