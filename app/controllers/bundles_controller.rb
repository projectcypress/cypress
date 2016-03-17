class BundlesController < ApplicationController
  before_action :find_bundle, only: [:set_default, :destroy]

  before_action :check_bundle_disabled_setting
  before_action :redirect_if_disabled, except: [:index]
  before_action :require_admin

  add_breadcrumb 'Bundles', :bundles_path
  add_breadcrumb 'Add Bundle', :new_bundle_path, only: [:new, :create]

  def check_bundle_disabled_setting
    @disabled = APP_CONFIG['disable_bundle_page']
  end

  def redirect_if_disabled
    if @disabled
      redirect_to bundles_url
      false
    end
  end

  def index
    @bundles = Bundle.all
  end

  def new
    @bundle = Bundle.new
  end

  def set_default
    Bundle.where(active: true).update_all(active: false)

    @bundle.active = true
    @bundle.save!

    redirect_to bundles_url
  end

  def update
  end

  def create
    # save file to a temporary location
    bundle_file = params['file']
    FileUtils.mkdir_p(APP_CONFIG.bundle_file_path)
    file_name = generate_file_path
    file_path = File.join(APP_CONFIG.bundle_file_path, file_name)
    FileUtils.mv(temp_file_path, file_path)
    BundleUploadJob.perform_later(file_path, bundle_file.original_filename)
    redirect_to bundles_url
  end

  def destroy
    @bundle.destroy

    # clear this cache just in case it's pointing to the bundle just deleted
    Rails.cache.delete('any_installed_bundle')

    redirect_to bundles_url
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

  def require_admin
    authorize! :manage, Bundle.new
  end
end
