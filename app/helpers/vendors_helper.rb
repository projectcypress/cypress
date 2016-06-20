module VendorsHelper
  def formatted_vendor_address(vendor)
    address = [vendor.address, vendor.state, vendor.zip].delete_if { |x| x == '' }
    address.count > 0 ? address.join(', ') : nil
  end

  # return value is nested hash structured like this:
  #   { certification_type: { product_test_type: { passing: #, failing: #, not_started: #, total: # } } }
  def get_product_status_values(product)
    Rails.cache.fetch("#{product.cache_key}/status_values") do
      h = {}
      h['C1'] = c1_status_values(product) if product.c1_test
      h['C2'] = c2_status_values(product) if product.c2_test
      h['C3'] = c3_status_values(product) if product.c3_test
      h['C4'] = c4_status_values(product.product_tests.filtering_tests) if product.c4_test
      h
    end
  end

  def c1_status_values(product)
    h = {}
    h['Manual'] = Hash[%w(passing failing not_started total).zip(checklist_status_values(product.product_tests.checklist_tests.first))]
    if h['Manual']['total'] == 0
      default_number = CAT1_CONFIG['number_of_checklist_measures']
      h['Manual']['not_started'] = product.measure_ids.size < default_number ? product.measure_ids.size : default_number
    end
    h['QRDA Category I'] = Hash[%w(passing failing not_started total).zip(product_test_statuses(product.product_tests.measure_tests, 'C1Task'))]
    h
  end

  def c2_status_values(product)
    h = {}
    h['QRDA Category III'] = Hash[%w(passing failing not_started total).zip(product_test_statuses(product.product_tests.measure_tests, 'C2Task'))]
    h
  end

  def c3_status_values(product)
    h = {}
    cat1_status_values = product.c1_test ? product_test_statuses(product.product_tests.measure_tests, 'C3Cat1Task') : [0, 0, 0, 0]
    cat3_status_values = product.c2_test ? product_test_statuses(product.product_tests.measure_tests, 'C3Cat3Task') : [0, 0, 0, 0]
    h['QRDA Category I'] = Hash[%w(passing failing not_started total).zip(cat1_status_values)]
    h['QRDA Category III'] = Hash[%w(passing failing not_started total).zip(cat3_status_values)]
    h
  end

  def c4_status_values(filtering_tests)
    h = {}
    h['QRDA Category I'] = Hash[%w(passing failing not_started total).zip(product_test_statuses(filtering_tests, 'Cat1FilterTask'))]
    h['QRDA Category III'] = Hash[%w(passing failing not_started total).zip(product_test_statuses(filtering_tests, 'Cat3FilterTask'))]
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
    when 'Incomplete'
      classes['cell'] = 'status-not-started'
      classes['icon'] = 'fa-circle-o'
    when 'Not_started'
      classes['cell'] = 'status-not-started'
      classes['icon'] = 'fa-circle-o'
    end

    classes
  end

  def vendor_statuses(vendor)
    h = {}
    h['passing'] = vendor.products_passing.count
    h['failing'] = vendor.products_failing.count
    h['incomplete'] = vendor.products_incomplete.count
    h['total'] = vendor.products.count
    h
  end
end
