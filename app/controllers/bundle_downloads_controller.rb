# frozen_string_literal: true

class BundleDownloadsController < ApplicationController
  add_breadcrumb 'Download Bundle', :bundle_downloads_path

  def index
    @bundle_download = BundleDownload.new
    @bundle_years = APP_CONSTANTS['version_config'].keys.map { |key| key[2, 4] }
  end

  def create
    api_key = params[:bundle_download][:api_key]
    bundle_year = params[:bundle_download][:bundle_year]
    bundle_file_name = "bundle-#{bundle_year}.zip"
    temp_file = download_bundle(api_key, bundle_file_name)
    send_file temp_file.path, type: 'application/zip', disposition: 'attachment', filename: bundle_file_name
    # redirect_to bundle_downloads_path
  end

  protected

  def download_bundle(api_key, bundle_file_name)
    bundle_resource = RestClient::Request.execute(method: :get,
                                                  url: "#{Settings.current.downloadable_bundles_path}#{bundle_file_name}",
                                                  user: 'NA',
                                                  password: api_key,
                                                  raw_response: true,
                                                  headers: { accept: :zip })
    bundle_resource.file
  end
end
