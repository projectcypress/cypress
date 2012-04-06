class ApplicationController < ActionController::Base
  layout :layout_by_resource

  protect_from_forgery

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
  
end