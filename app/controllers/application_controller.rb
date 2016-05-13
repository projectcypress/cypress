class ApplicationController < ActionController::Base
  include Roar::Rails::ControllerAdditions

  # Prevent CSRF attacks with a null session
  protect_from_forgery :with => :exception, :unless => -> { request.format.json? || request.format.xml? }

  before_action :authenticate_user!, :check_bundle_installed, :check_backend_jobs, except: [:page_not_found, :server_error]
  around_action :catch_not_found

  rescue_from CanCan::AccessDenied do |exception|
    render text: exception, status: 401
  end

  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/404', layout: 'layouts/errors', status: 404 }
      format.all  { render text: '404 Not Found', status: 404 }
    end
  end

  def server_error
    respond_to do |format|
      format.html { render template: 'errors/500', layout: 'layouts/errors', status: 500 }
      format.all  { render text: '500 Server Error', status: 500 }
    end
  end

  private

  DEFAULT_AUTH_MAPPING = { read: %w(show index), manage: %w(new create update destroy delete edit) }.freeze
  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    user_session_path
  end

  def any_bundle
    Rails.cache.fetch('any_installed_bundle') do
      # cache this so that in the normal case, when the bundles are installed
      # it doesn't query the db on every request
      HealthDataStandards::CQM::Bundle.all.sample
    end
  end

  # if the jobs are not running then there will be no pid files in the pid direectory
  # they will not be running if the pid directory is not avaialable which will cause an
  # exception to be thrown
  def check_backend_jobs
    running = false
    begin
      running = !Dir.new(APP_CONFIG.pid_dir).entries.empty?
    rescue
    end

    unless running
      alert_msg = "The backend processes for setting up tests and performing measure calculations are not running.
                    Please refer to the Cypress installation manual for instructions on starting the processes."
      flash[:backend_job_alert] = alert_msg.html_safe
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
    @vendor = params[:vendor_id] ? Vendor.find(params[:vendor_id]) : Vendor.find(params[:id])
    @title = @vendor.name
  end

  def set_product
    product_finder = @vendor ? @vendor.products : Product
    @product = params[:product_id] ? product_finder.find(params[:product_id]) : product_finder.find(params[:id])
    @title = @product.name
  end

  def set_product_test
    @product_test = params[:product_test_id] ? ProductTest.find(params[:product_test_id]) : ProductTest.find(params[:id])
    @title = "#{@product_test.product.name} C1 Manual Test" if @product_test.is_a?(ChecklistTest)
  end

  def set_task
    @task = params[:task_id] ? Task.find(params[:task_id]) : Task.find(params[:id])
    @title = "#{@task.product_test.product.name} #{@task.product_test.cms_id} #{@task._type.titleize}"
  end

  def set_test_execution
    @test_execution = params[:test_execution_id] ? TestExecution.find(params[:test_execution_id]) : TestExecution.find(params[:id])
  end

  def flash_comment(name, notice_type, message)
    # message should be past tense to make grammatical sense
    flash[:notice] = "'#{name}' was #{message}."
    flash[:notice_type] = notice_type
  end

  def authorize_request(vendor, auth_map = {})
    ability ||= required_ability(auth_map) || required_ability(DEFAULT_AUTH_MAPPING) || :manage
    authorize! ability, vendor
  end

  def required_ability(auth_map)
    ability = nil
    auth_map.each_pair do |k, actions|
      ability = k if actions.is_a?(Array) && actions.include?(params[:action])
    end
    ability
  end

  def catch_not_found
    yield
  rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    render :nothing => true, :status => :not_found
  end
end
