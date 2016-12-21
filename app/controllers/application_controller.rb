class ApplicationController < ActionController::Base
  include Roar::Rails::ControllerAdditions

  # Prevent CSRF attacks with a null session
  protect_from_forgery :with => :exception, :unless => -> { request.format.json? || request.format.xml? }

  before_action :authenticate_user!, :check_bundle_installed, :check_backend_jobs, except: [:page_not_found, :server_error]
  around_action :catch_not_found

  helper_method :mode_internal?, :mode_demo?, :mode_atl?

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

  def mode_internal?
    Cypress::AppConfig['auto_approve'] && Cypress::AppConfig['ignore_roles'] && Cypress::AppConfig['enable_debug_features'] &&
      Cypress::AppConfig['default_role'].nil?
  end

  def mode_demo?
    Cypress::AppConfig['auto_approve'] && !Cypress::AppConfig['ignore_roles'] && Cypress::AppConfig['enable_debug_features'] &&
      Cypress::AppConfig['default_role'] == :user
  end

  def mode_atl?
    !Cypress::AppConfig['auto_approve'] && !Cypress::AppConfig['ignore_roles'] && !Cypress::AppConfig['enable_debug_features'] &&
      Cypress::AppConfig['default_role'].nil?
  end

  def application_mode
    return 'Internal' if mode_internal?
    return 'Demo' if mode_demo?
    return 'ATL' if mode_atl?
    'Custom'
  end

  private

  DEFAULT_AUTH_MAPPING = { read: %w(show index), manage: %w(new create update destroy delete edit) }.freeze
  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    user_session_path
  end

  def any_bundle
    if Rails.cache.exist?('any_installed_bundle')
      bundle = Rails.cache.read('any_installed_bundle')
    else
      bundle = HealthDataStandards::CQM::Bundle.all.sample
      # Only cache the bundle if it is not nil
      Rails.cache.write('any_installed_bundle', bundle) if bundle
    end
    bundle
  end

  # if the jobs are not running then there will be no pid files in the pid direectory
  # they will not be running if the pid directory is not avaialable which will cause an
  # exception to be thrown
  def check_backend_jobs
    running = false
    begin
      running = !Dir.new(Cypress::AppConfig['pid_dir']).entries.empty?
    rescue
    end

    unless running
      alert_msg = "The backend processes for setting up tests and performing measure calculations are not running.
                    Please refer to the Cypress installation manual for instructions on starting the processes."
      flash[:backend_job_alert] = alert_msg.html_safe
    end
  end

  def check_bundle_installed
    unless any_bundle
      install_instr = Cypress::AppConfig['references']['install_guide']

      install_instr_link = view_context.link_to install_instr['title'], install_instr['url']

      flash.now[:no_bundle_alert] = "There are no bundles currently available.
                                      Please follow the #{install_instr_link} to get started.".html_safe
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

  def flash_comment(name, notice_type, verb)
    flash[notice_type] ||= [] # don't overwrite other messages of this type
    flash[notice_type] << "'#{name}' was #{verb}." # message should be past tense to make grammatical sense
  end

  def authorize_request(vendor, auth_map = {})
    ability ||= required_ability(auth_map) || required_ability(DEFAULT_AUTH_MAPPING) || :manage
    authorize! ability, vendor
  end

  def required_ability(auth_map)
    ability = nil
    auth_map.each_pair { |k, actions| ability = k if actions.is_a?(Array) && actions.include?(params[:action]) }
    ability
  end

  def catch_not_found
    yield
  rescue Mongoid::Errors::DocumentNotFound, Mongoid::Errors::InvalidFind
    page_not_found
  end
end
