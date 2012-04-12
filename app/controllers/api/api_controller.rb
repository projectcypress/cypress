module Api
  class ApiController < ApplicationController
    before_filter :authenticate_user!
    def find_vendor
      @vendor = current_user.vendors.find(params[:vendor_id])
    end
    
    def find_product
      # binding.pry
      find_vendor unless @vendor
      @product = @vendor.products.find(params[:product_id])
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
  
end
