class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery :with => :exception

  # breadcrumbs
  add_breadcrumb 'All Vendors', :vendors_path
  before_action :authenticate_user!, :check_bundle_installed

  private

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    user_session_path
  end

  def any_bundle
    Rails.cache.fetch('any_installed_bundle') do
      # cache this so that in the normal case, when the bundles are installed
      # it doesn't query the db on every request
      HealthDataStandards::CQM::Bundle.first
    end
  end

  def check_bundle_installed
    unless any_bundle
      # this is a hack - ideally we wouldn't cache nil in the first place
      # but this forces it to check every time only if it wasn't found before
      Rails.cache.delete('any_installed_bundle')

      bundle_2015 = view_context.link_to '2015 Cypress 3.0 Test Bundle', 'http://demo.projectcypress.org/bundles/bundle-3.0.0-2015.zip'
      bundle_2016 = view_context.link_to '2016 Cypress 3.0 Test Bundle', 'http://demo.projectcypress.org/bundles/bundle-3.0.0-2016.zip'
      install_instr = view_context.link_to 'Cypress 3.0 Install Instructions', 'https://github.com/projectcypress/cypress/wiki/Cypress-3.0-Install-Instructions'

      alert = "There are no bundles currently available.
               To use Cypress, please download and import either the #{bundle_2015} or the #{bundle_2016}.
                For more information, see the #{install_instr}."

      flash[:alert] = alert.html_safe
    end
  end
end
