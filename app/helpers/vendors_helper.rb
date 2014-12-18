module VendorsHelper

  def products_by_status(vendor)

    failing_products = vendor.failing_products
    passing_products = vendor.passing_products
    incomplete = vendor.incomplete_products
    { 'fail' => failing_products, 'pass' => passing_products , 'incomplete' => incomplete}

  end

  def test_status(test)
    case test.execution_state
      when :passed then 'pass'
      when :pending then 'pending'
      else
       'fail'
    end
  end


  def display_passing_products(vendor)
    "#{vendor.count_passing} products"
  end

  def display_failing_products(vendor)
    "#{vendor.count_failing} products"
  end

  def display_tested_products(vendor)
    "#{vendor.count_tested.to_s} / #{vendor.products.size.to_s } products"
  end

end
