module VendorsHelper
  def formatted_vendor_address(vendor)
    address = [vendor.address, vendor.state, vendor.zip].delete_if { |x| x == '' }
    address.count > 0 ? address.join(', ') : nil
  end

  # return value is nested hash structured like this:
  #   { certification_type: { product_test_type: { passing: #, failing: #, not_started: #, total: # } } }
  #   href in hash is used as a unique identifier for certification specifics popup
  def get_product_status_values(product)
    Rails.cache.fetch("#{product.cache_key}/status_values") do
      h = {}
      h['C1'] = c1_values(product) if product.c1_test
      h['C2'] = c2_values(product) if product.c2_test
      h['C3'] = c3_values(product) if product.c3_test
      h['C4'] = c4_values(product) if product.c4_test
      h
    end
  end

  def c1_values(product)
    h = {}
    h['checklist'] = Hash[%w(passing failing not_started total).zip(checklist_status_values(product.product_tests.checklist_tests.first))]
    if h['checklist']['total'] == 0
      h['checklist']['not_started'] = product.measure_ids.size > 3 ? 4 : product.measure_ids.size
    end
    h['cat1'] = Hash[%w(passing failing not_started total).zip(product_test_status_values(product.product_tests.measure_tests, 'C1Task'))]
    h['sums'] = h['cat1'].merge(h['checklist']) { |_key, old_val, new_val| old_val + new_val }
    h['href'] = "product_#{product.id}_c1"
    h['checklist']['display_name'] = 'Manual'
    h['cat1']['display_name'] = 'Cat I'
    h
  end

  def c2_values(product)
    h = {}
    h['cat3'] = Hash[%w(passing failing not_started total).zip(product_test_status_values(product.product_tests.measure_tests, 'C2Task'))]
    h['sums'] = h['cat3'].merge({})
    h['href'] = "product_#{product.id}_c2"
    h['cat3']['display_name'] = 'Cat III'
    h
  end

  def c3_values(product)
    h = {}
    cat1_status_values = product.c1_test ? product_test_status_values(product.product_tests.measure_tests, 'C3Cat1Task') : [0, 0, 0, 0]
    cat3_status_values = product.c2_test ? product_test_status_values(product.product_tests.measure_tests, 'C3Cat3Task') : [0, 0, 0, 0]
    h['cat1'] = Hash[%w(passing failing not_started total).zip(cat1_status_values)]
    h['cat3'] = Hash[%w(passing failing not_started total).zip(cat3_status_values)]
    h['sums'] = h['cat1'].merge(h['cat3']) { |_key, old_val, new_val| old_val + new_val }
    h['href'] = "product_#{product.id}_c3"
    h['cat1']['display_name'] = 'Cat I'
    h['cat3']['display_name'] = 'Cat III'
    h
  end

  def c4_values(product)
    h = {}
    h['cat1'] = Hash[%w(passing failing not_started total).zip(product_test_status_values(product.product_tests.filtering_tests, 'Cat1FilterTask'))]
    h['cat3'] = Hash[%w(passing failing not_started total).zip(product_test_status_values(product.product_tests.filtering_tests, 'Cat3FilterTask'))]
    h['sums'] = h['cat1'].merge(h['cat3']) { |_key, old_val, new_val| old_val + new_val }
    h['href'] = "product_#{product.id}_c4"
    h['cat1']['display_name'] = 'Cat I'
    h['cat3']['display_name'] = 'Cat III'
    h
  end

  # status should be 'Passing', 'Failing', or 'Not Complete'
  # used for each certification status on vendor show page
  def status_to_css_classes(status)
    classes = {}

    case status
    when 'Passing'
      classes['cell'] = 'status-passing'
      classes['icon'] = 'fa-check'
    when 'Failing'
      classes['cell'] = 'status-failing'
      classes['icon'] = 'fa-times'
    else
      classes['cell'] = 'status-not-started'
      classes['icon'] = 'fa-circle-o'
    end

    classes
  end
end
