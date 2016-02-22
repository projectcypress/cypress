class MeasureTest < ProductTest
  validate :at_most_one_measure?

  def at_most_one_measure?
    errors.add(:measure_ids, 'MeasureTest must have a single measure id') if measure_ids.length != 1
  end

  after_create do |product_test|
    product_test.queued
    ProductTestSetupJob.perform_later(product_test)
    create_tasks
  end

  # only creates c1, c2, and c3 tasks with no attributes as of now ~ JaeBird
  # as of now, should only create one task per task type
  def create_tasks
    product_c1_and_c2_if_only_c3(product)
    if product.c1_test
      C1Task.new(product_test: self).save!
      C3Cat1Task.new(product_test: self).save! if product.c3_test
    end
    if product.c2_test
      C2Task.new(product_test: self).save!
      C3Cat3Task.new(product_test: self).save! if product.c3_test
    end
  end

  def product_c1_and_c2_if_only_c3(product)
    if product.c3_test && !product.c1_test && !product.c2_test
      product.c1_test = true
      product.c2_test = true
    end
  end
end
