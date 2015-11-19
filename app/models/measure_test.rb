class MeasureTest < ProductTest
  validate :at_most_one_measure?

  def at_most_one_measure?
    errors.add(:measure_ids, 'MeasureTest must have a single measure id') if measure_ids.length != 1
  end

  after_create :create_tasks

  # only creates c1, c2, and c3 tasks with no attributes as of now ~ JaeBird
  # as of now, should only create one task per task type
  def create_tasks
    # if the user only chooses c3, then imply the user wanted c1, c2, and c3
    if product.c3_test && !product.c1_test && !product.c2_test
      product.c1_test = true
      product.c2_test = true
    end
    C1Task.new(product_test: self).save! if product.c1_test
    C2Task.new(product_test: self).save! if product.c2_test
    C3Task.new(product_test: self).save! if product.c3_test
  end

  # returns c1_task if has any
  # returns false if has no c1 task
  def c1_task
    c1_tasks = tasks.select { |task| task._type == 'C1Task' }
    if c1_tasks.empty?
      false
    else
      c1_tasks.first
    end
  end

  # returns c2_task if has any
  # returns false if has no c2 task
  def c2_task
    c2_tasks = tasks.select { |task| task._type == 'C2Task' }
    if c2_tasks.empty?
      false
    else
      c2_tasks.first
    end
  end

  # returns c3_task if has any
  # returns false if has no c3 task
  def c3_task
    c3_tasks = tasks.select { |task| task._type == 'C3Task' }
    if c3_tasks.empty?
      false
    else
      c3_tasks.first
    end
  end
end
