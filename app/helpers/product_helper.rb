module ProductHelper
  def product_tests_by_status(product)
    failing_tests = product.failing_tests
    passing_tests = product.passing_tests
    { 'fail' => failing_tests, 'pass' => passing_tests}
  end
  
end