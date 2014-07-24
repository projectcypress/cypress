
class MeasuresController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_test_and_execution, only: [:show, :patients]
  before_filter :find_measure, only: [:show,:patients]
  before_filter :find_product, only: [:show,:patients,:minimal_set]

  def by_type

    test = test_type(params[:type])
    bundle = Bundle.find(params[:bundle_id])
    @measures = test.product_type_measures(bundle)

    @measures_categories = @measures.group_by { |t| t.category }

    respond_to do |format|
      format.js { render :layout => false }
      format.json {render :json => {:measures => @measures, :measures_categories => @measures_categories}}
    end

  end


  def show

    @vendor = @product.vendor
    @measures = @test.measures
    @measures_categories = @measures.group_by { |t| t.category }


    respond_to do |format|
      format.json { render :json => @execution.expected_results }
      format.html { render :action => "show" }
    end
  end

  def definition
    render :json => Measure.where(_id: params[:measure_id]).first
  end

  def patients

    @vendor = @product.vendor
    @result = @execution.expected_result(@measure)
    @selected = @measure
    @patients = @test.results.where("value.measure_id" => @measure.hqmf_id, "value.sub_id" => @measure.sub_id)


    @patients = @patients.order_by([["value.NUMER", :desc],["value.DENOM", :desc],["value.DENEX", :desc]])
    render :template=> "patients/table", :layout => false
  end

  private


  def find_product
    if @test.nil?
      @product = Product.find(params[:id]) if params[:id]
      @product = Product.find(params[:product_id]) if params[:product_id]
    else
      @product = @test.product
    end

  end

  def find_measure
    @measure = Measure.where(_id: params[:id]).first
  end


  def find_test_and_execution
    @test = ProductTest.find(params[:product_test_id])
    if params[:execution_id]
      @execution = TestExecution.find(params[:execution_id])
    elsif @test.test_executions.size > 0
      @execution = @test.test_executions.first
    else
      @execution = TestExecution.new({:product_test => @test, :execution_date => Time.now})
    end
  end

end
