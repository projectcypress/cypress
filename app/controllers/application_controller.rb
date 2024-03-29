# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Roar::Rails::ControllerAdditions

  # Prevent CSRF attacks with a null session
  protect_from_forgery with: :exception, unless: -> { request.format.json? || request.format.xml? }

  before_action :restrict_basic_auth, :authenticate_user!, :check_bundle_installed, :check_backend_jobs,
                :check_remaining_disk_space, except: %i[page_not_found server_error]
  around_action :catch_not_found

  rescue_from CanCan::AccessDenied do |exception|
    render plain: exception, status: :unauthorized
  end

  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/404', layout: 'layouts/errors', status: :not_found }
      format.all  { render plain: '404 Not Found', status: :not_found }
    end
  end

  def server_error
    respond_to do |format|
      format.html { render template: 'errors/500', layout: 'layouts/errors', status: :internal_server_error }
      format.all  { render plain: '500 Server Error', status: :internal_server_error }
    end
  end

  def require_admin
    raise CanCan::AccessDenied.new, 'Forbidden' unless current_user.user_role? :admin
  end

  def require_admin_atl
    return if current_user.user_role?(:admin) || current_user.user_role?(:atl) || Settings.current.enable_debug_features

    raise CanCan::AccessDenied.new, 'Forbidden'
  end

  private

  DEFAULT_AUTH_MAPPING = { read: %w[show index], manage: %w[new create update destroy delete edit] }.freeze
  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(_resource_or_scope)
    user_session_path
  end

  def any_bundle
    if Rails.cache.exist?('any_installed_bundle')
      bundle = Rails.cache.read('any_installed_bundle')
    else
      bundle = Bundle.available.all.sample
      # Only cache the bundle if it is not nil
      Rails.cache.write('any_installed_bundle', bundle) if bundle
    end
    bundle
  end

  def check_remaining_disk_space
    Vmstat.snapshot.disks.each do |disk|
      disk_percentage = 100 - ((disk.available_blocks / disk.total_blocks.to_f) * 100).round
      disk_full_msg = "Your disk is #{disk_percentage}% full, please check your remaining hard disk space and " \
                      'clean up old tests in order to ensure continued stable operation of the Cypress application.'
      flash.now[:disk_space_danger] = disk_full_msg if disk_percentage >= 95
    end
  end

  # Check the running processes to see if there is a delayed job runner running.
  # The assumption here is that there is only 1 application running on this server
  # and thus any background workers found will be dedicated to Cypress.
  def check_backend_jobs
    running = `pgrep -f jobs:work`.split("\n").count.positive?

    return if running

    alert_msg = 'The backend processes for setting up tests and performing measure calculations are not running.
                  Please refer to the Cypress installation manual for instructions on starting the processes.'
    flash[:backend_job_warning] = alert_msg
  end

  def check_bundle_deprecated
    deprecation_msg = 'The bundle this product is using has been deprecated. ' \
                      'You will still be able to run test executions however ' \
                      'no new products will be able to be created using this bundle.'
    current_product = @product || @task&.product_test&.product || @product_test&.product
    return unless current_product&.bundle&.deprecated?

    flash.now['warning'] ||= []
    flash.now['warning'] << deprecation_msg
  end

  def check_bundle_installed
    return if any_bundle

    install_instr = APP_CONSTANTS['references']['install_guide']

    install_instr_link = view_context.link_to install_instr['title'], install_instr['url']

    flash.now[:no_bundle_alert] = "There are no bundles currently available.
                                    Please follow the #{install_instr_link} to get started.".html_safe
  end

  # Clear basic auth token if user is not using the JSON API. This fixes a bug where basic auth
  # causes the application to enter an inconsistent state by clearing any basic auth credentials
  # if the application is not accessed via a JSON endpoint.
  def restrict_basic_auth
    request.env['HTTP_AUTHORIZATION'] = '' unless request.format.symbol.eql?(:json) || request.format.symbol.eql?(:xml)
  end

  def set_vendor
    @vendor = Vendor.find(params[:vendor_id] || params[:id])
    @title = @vendor.name
  end

  def set_product
    product_finder = @vendor ? @vendor.products : Product
    @product = product_finder.find(params[:product_id] || params[:id])
    @title = @product.name
  end

  def set_product_test
    @product_test = ProductTest.find(params[:product_test_id] || params[:id])
    @title = "#{@product_test.product_name} C1 Record Sample" if @product_test.is_a?(ChecklistTest)
  end

  def set_task
    @task = Task.find(params[:task_id] || params[:id])
    @title = "#{@task.product_test.product_name} #{@task.product_test_cms_id} #{@task._type.titleize}"
  end

  def set_test_execution
    @test_execution = TestExecution.find(params[:test_execution_id] || params[:id])
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
