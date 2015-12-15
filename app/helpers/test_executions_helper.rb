module TestExecutionsHelper
  def get_certification_types(task)
    if currently_viewing_c1?(task)
      certification_types = 'C1'
    else
      certification_types = 'C2'
    end
    certification_types << ' and C3' if task.product_test.product.c3_test
    certification_types
  end

  def get_other_certification_types(task)
    if currently_viewing_c1?(task)
      other_certification_types = 'C2'
    else
      other_certification_types = 'C1'
    end
    other_certification_types << ' and C3' if task.product_test.product.c3_test
    other_certification_types
  end

  def get_upload_type(task)
    if currently_viewing_c1?(task)
      'CAT 1 zip'
    else
      'CAT 3 XML'
    end
  end

  # returns:
  #   c1 task if we are currently on the c2 task page
  #   c2 task if we are currently on the c1 task page
  #   false if the user did not select the other task when creating the product
  def get_other_task(task)
    if currently_viewing_c1?(task)
      task.product_test.c2_task
    else
      task.product_test.c1_task
    end
  end

  def get_select_history_message(execution, is_most_recent)
    msg = ''
    msg << 'Most Recent - ' if is_most_recent
    msg << execution.created_at.in_time_zone('Eastern Time (US & Canada)').strftime('%b %d, %Y at %I:%M %p (%A)')
    msg << ' (passing)' if execution.passing?
    msg << ' (in progress)' if execution.incomplete?
    msg << " (#{execution.execution_errors.count} errors)" if execution.failing?
    msg
  end

  private

  def currently_viewing_c1?(task)
    task._type == 'C1Task'
  end
end
