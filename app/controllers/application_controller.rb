class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protect_from_forgery

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :render_500
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from ActionController::UnknownController, with: :render_404
    rescue_from AbstractController::ActionNotFound, with: :render_404
  end

  protected

  def layout_by_resource
    if devise_controller?
      "devise"
    else
      "application"
    end
  end
  
  def find_product_test
    find_product unless @product
    @product_test = @product.product_tests.find(params[:product_test_id])
  end
  
  def find_test_execution
    find_product_test unless @product_test
    @test_execution = @product_test.test_executions.find(params[:test_execution_id])
  end
  
  def find_measure
    @measure = Measure.find(params[:mesure_id])
  end
  
  def find_patient_population
    @patient_population = PatientPopulation.find(params[:patient_population_id])
  end
  
  def render_404(exception)
    @not_found_path = exception.message
    respond_to do |format|
      format.html { render template: 'errors/error_404', layout: 'layouts/application', status: 404 }
      format.all { render nothing: true, status: 404 }
    end
  end

  def render_500(exception)
    @error = exception
    respond_to do |format|
      format.html { render template: 'errors/error_500', layout: 'layouts/application', status: 500 }
      format.all { render nothing: true, status: 500}
    end
  end  
end