class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery :with => :exception

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
    if any_bundle
      flash.delete :alert if flash[:alert] && flash[:alert].include?('There are no bundles currently available')
      # shouldn't be necessary but the flash alert seems to stick around one pageload after a bundle is installed
    else
      # this is a hack - ideally we wouldn't cache nil in the first place
      # but this forces it to check every time only if it wasn't found before
      Rails.cache.delete('any_installed_bundle')

      bundle_references = APP_CONFIG['references']['bundles']
      prev_bundle = bundle_references['previous']
      curr_bundle = bundle_references['current']
      install_instr = APP_CONFIG['references']['install_guide']

      prev_bundle_link = view_context.link_to prev_bundle['title'], prev_bundle['url']
      curr_bundle_link = view_context.link_to curr_bundle['title'], curr_bundle['url']
      install_instr_link = view_context.link_to install_instr['title'], install_instr['url']

      alert = "There are no bundles currently available.
               To use Cypress, please download and import either the #{prev_bundle_link} or the #{curr_bundle_link}.
                For more information, see the #{install_instr_link}."

      flash[:alert] = alert.html_safe
    end
  end

  def set_vendor
    @vendor ||= params[:vendor_id] ? Vendor.find(params[:vendor_id]) : Vendor.find(params[:id])
  end

  def set_product
    product_finder = @vendor ? @vendor.products : Product
    @product ||= params[:product_id] ? product_finder.find(params[:product_id]) : product_finder.find(params[:id])
  end

  def set_product_test
    @product_test ||= params[:product_test_id] ? ProductTest.find(params[:product_test_id]) : ProductTest.find(params[:id])
  end

  def set_task
    @task ||= params[:task_id] ? Task.find(params[:task_id]) : Task.find(params[:id])
  end

  def set_test_execution
    @test_execution ||= params[:test_execution_id] ? TestExecution.find(params[:test_execution_id]) : TestExecution.find(params[:id])
  end

  def flash_comment(name, notice_type, message)
    # message should be past tense to make grammatical sense
    flash[:notice] = "'#{name}' was #{message}."
    flash[:notice_type] = notice_type
  end
end
