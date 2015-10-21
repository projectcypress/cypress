class C4Task < Task
  def after_create
    # generate expected results here.  Will need to gen quailty report
    # for each of the measures in the product_test but constrainted to the
    # filter provided for test.  Filter data should live in the options field
    # that is defined in Task
  end

  def execute(_params)
  end
end
