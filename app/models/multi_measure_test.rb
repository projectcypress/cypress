class MultiMeasureTest < ProductTest
  field :reporting_program_type, type: String

  after_create do |product_test|
    product_test.queued
    ProductTestSetupJob.perform_later(product_test)
    create_tasks
  end

  def create_tasks
    MultiMeasureCat3Task.new(product_test: self).save! if reporting_program_type == 'ep'
    MultiMeasureCat1Task.new(product_test: self).save! if reporting_program_type == 'eh'
  end
end
