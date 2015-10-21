class C4Task < Task

  def after_create
    # generate expected results here.  Will need to gen quailty report 
    # for each of the measures in the product_test but constrainted to the 
    # filter provided for test.  Filter data should live in the options field
    # that is defined in Task 
  end

  def execute(params)

  end


  def build_patient_filter

  end

  # this will fetch the records associted with the product test but constrainted according to the 
  # filters configured for the task
  def records
    product_test.records.where(build_patient_filter)
  end

end