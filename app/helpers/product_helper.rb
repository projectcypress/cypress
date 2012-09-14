module ProductHelper
  def product_tests_by_status(product)
    failing_tests = product.failing_tests
    passing_tests = product.passing_tests
    { 'fail' => failing_tests, 'pass' => passing_tests, "incomplete" => product.incomplete_tests}
  end

  def last_execution(product)
	executions = product.product_tests.collect do |test|
      test.test_executions.empty? ? nil : test.test_executions.ordered_by_date.to_a.last
    end
    executions.flatten.max
  end

  def display_last_execution(product)
    ex = last_execution(product)	
    ex.nil? ? '' : ex.to_s
  end

  def display_passing_tests(product)
  	"#{product.count_passing} /  #{product.product_tests.size} tests'"
  end

  def display_failing_tests(product)
	"#{product.count_failing} /  #{product.product_tests.size} tests'"
  end

  
end