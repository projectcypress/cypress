class Admin::BundlesController < ApplicationController
  before_action :require_admin
  def index
    @bundles = Bundle.all
  end

  def import
    # store file to some location so the job can pick it up.
    BundleImportJob.perform_later(bundle_path)
  end

  def toggle_enabled
    @bundle = Bundle.find(params[:id])
    @bundle.enabled = !@bundle.enabled
    @bundle.save
  end

  def destroy
    Bundle.find(params[:id]).destroy
  end

  private

  def require_admin
    fail 404 unless current_user.has_role? :admin
  end
end
