# frozen_string_literal: true

class TestExecutionsController < ApplicationController
  include Api::Controller
  include TestExecutionsHelper
  include Cypress::ErrorCollector

  before_action :set_test_execution, only: %i[show destroy file_result]
  before_action :set_task, only: %i[index new create]
  before_action :set_task_from_test_execution, only: %i[show file_result]
  before_action :set_product_test_from_task, only: %i[show new file_result]
  before_action :add_breadcrumbs, only: %i[show new]
  before_action :check_bundle_deprecated, only: %i[show index new]

  respond_to :js, only: %i[show create]

  def index
    @test_executions = @task.test_executions
    respond_with(@test_executions.to_a)
  end

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/BlockLength
  def create
    authorize! :execute_task, @task.product_test.product.vendor

    @task.latest_test_execution_id = nil
    @task.save
    @test_execution = @task.execute(results_params, current_user)

    respond_to do |format|
      format.turbo_stream do
        if @task.is_a?(Cat1FilterTask) || @task.is_a?(Cat3FilterTask)
          frame_id = "product_#{params['test_execution']['html_id']}_upload_frame"

          render turbo_stream: turbo_stream.replace(
            frame_id,
            partial: 'products/filtering_test_status_display_controller',
            locals: {
              product_url: params['test_execution']['product_url'],
              task: @task,
              product: @task.product_test.product,
              html_id: params['test_execution']['html_id'],
              reload: true
            }
          )
        else
          product = @task.product_test.product
          html_id = params.dig('test_execution', 'html_id')
          include_c1 = params.dig('test_execution', 'include_c1')
          product_url = params.dig('test_execution', 'product_url')

          render turbo_stream: turbo_stream.replace(
            view_context.measure_tests_table_row_wrapper_id(@task),
            partial: 'products/measure_tests_table_row',
            locals: {
              task: @task,
              has_eh_tests: product.eh_tests?,
              has_ep_tests: product.ep_tests?,
              html_id: html_id,
              include_c1: include_c1,
              product_url: product_url
            }
          )
        end
      end

      format.html do
        if @task.is_a? C1ChecklistTask
          redirect_to product_checklist_test_path(@task.product_test.product, @task.product_test), status: :see_other
        elsif @task.is_a? CMSProgramTask
          redirect_to product_program_test_path(@task.product_test.product, @task.product_test), status: :see_other
        else
          redirect_to task_test_execution_path(task_id: @task.id, id: @test_execution.id), status: :see_other
        end
      end

      format.xml do
        respond_with(@test_execution)
      end

      format.json do
        respond_with(@test_execution)
      end
    end
  rescue Mongoid::Errors::Validations
    rescue_create
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/BlockLength

  def new
    authorize! :execute_task, @product_test.product.vendor
    if @task.most_recent_execution
      redirect_to task_test_execution_path(task_id: @task.id, id: @task.most_recent_execution.id)
      return
    end
    render :show
  end

  def show
    @individual_results = CQM::IndividualResult.where(
      correlation_id: params['id']
    ).only(:IPP, :DENOM, :NUMER, :NUMEX, :DENEX, :DENEXCEP, :MSRPOPL, :OBSERV, :MSRPOPLEX,
           :measure_id, :patient_id, :file_name, :population_set_key, :statement_results, :episode_results).to_a
    authorize! :read, @task.product_test.product.vendor
    respond_to do |format|
      format.html
      format.turbo_stream
      format.xml do
        respond_with(@test_execution)
      end
      format.json do
        respond_with(@test_execution)
      end
    end
  end

  def destroy
    authorize! :delete, @test_execution.task.product_test.product.vendor
    test_executions = TestExecution.where(task_id: @test_execution.task.id)
    test_execution_ids = test_executions.pluck(:_id)
    test_executions.delete
    Artifact.where(:test_execution_id.in => test_execution_ids).destroy
    render body: nil, status: :no_content
  end

  def file_result
    authorize! :execute_task, @product_test.product.vendor
    add_breadcrumbs
    add_breadcrumb "File Results: #{route_file_name(params[:file_name])}"
    @file_name, @error_result = file_name_and_error_result_from_execution(@test_execution)
    @patient = Patient.where(correlation_id: @test_execution.id, file_name: @file_name).first
    @individual_results = @patient&.calculation_results
  end

  private

  def rescue_create
    alert = 'Invalid file upload. Please make sure you upload an XML or zip file.'
    error_response = { errors: [{ field: 'results',
                                  messages: ['invalid file upload. upload a zip for QRDA Category I or XML for QRDA Category III'] }] }
    respond_with(@test_execution) do |f|
      f.html { redirect_to new_task_test_execution_path(task_id: @task.id), flash: { alert: alert.html_safe } }
      f.json { render json: error_response, status: :unprocessable_entity }
      f.xml  { render xml: error_response[:errors].to_xml(root: :errors, skip_types: true), status: :unprocessable_entity }
    end
  end

  def set_task_from_test_execution
    @task = @test_execution.task
  end

  def set_product_test_from_task
    @product_test = @task.product_test
  end

  def add_breadcrumbs
    product = @product_test.product
    add_breadcrumb 'Dashboard', :vendors_path
    add_breadcrumb "Vendor: #{product.vendor_name}", vendor_path(product.vendor)
    add_breadcrumb "Product: #{product.name}", vendor_product_path(product.vendor, product)
    add_breadcrumb 'Record Sample Test', product_checklist_test_path(product, @product_test) if @product_test.is_a? ChecklistTest
    add_test_execution_breadcrumb
  end

  def add_test_execution_breadcrumb
    if @task.most_recent_execution
      add_breadcrumb "Test: #{@product_test.name}", task_test_execution_path(task_id: @task.id, id: @task.most_recent_execution.id)
    else
      add_breadcrumb "Test: #{@product_test.name}", ''
    end
  end

  def results_params
    # reqests from outside test execution page will have :results inside :test_execution in params
    if params[:results]
      params[:results]
    elsif params[:test_execution]
      params[:test_execution][:results]
    end
  end
end
