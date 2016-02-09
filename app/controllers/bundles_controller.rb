class BundlesController < ApplicationController
  before_action :find_bundle, only: [:set_default, :destroy]

  add_breadcrumb 'Bundles', :bundles_path
  add_breadcrumb 'Add Bundle', :new_bundle_path, only: [:new, :create]

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
    options = { delete_existing: false, type: 'ALL', update_measures: false, exclude_results: false }

    bundle_file = params['file']

    fail 'Bundle must be a Zip file' unless File.extname(bundle_file.original_filename) == '.zip'

    already_have_default = Bundle.where(active: true).exists?

    importer = HealthDataStandards::Import::Bundle::Importer
    @bundle = importer.import(bundle_file.tempfile, options)

    if already_have_default
      @bundle.active = false
      @bundle.save!
    end

    redirect_to bundles_url
  rescue => e
    flash[:alert] = e
    render :new
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
end
