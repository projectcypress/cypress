class TestExecutionsController < ApplicationController
  before_action :set_test_execution, only: [:destroy, :show]
  before_action :set_task, only: [:index, :new, :create]

  def index
    @test_executions = @task.test_executions
  end

  def create
    @test_execution = @task.execute(params[:results])
    redirect_to "/products/#{@task.product_test.product.id}/product_tests/#{@task.product_test.id}"
  end

  def show
  end

  def destroy
    @test_execution.destroy
    render status: 204, text: 'Deleted'
  end

  private

  def set_task
    @task = Task.find(params[:task_id])
  end

  def set_test_execution
    @test_execution = TestExecution.find(params[:id])
  end
end
