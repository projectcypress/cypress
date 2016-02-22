module VendorsHelper
  def formatted_vendor_address(vendor)
    address = [vendor.address, vendor.state, vendor.zip].delete_if { |x| x == '' }
    address.count > 0 ? address.join(', ') : nil
  end

  # return value is nested hash structured like this:
  #   { certification_type: { product_test_type: { passing: #, failing: #, not_started: #, total: # } } }
  #   href in hash is used as a unique identifier for certification specifics popup
  def get_product_status_values(product)
    h = {}
    h['C1'] = c1_values(product) if product.c1_test
    h['C2'] = c2_values(product) if product.c2_test
    h['C3'] = c3_values(product) if product.c3_test
    h['C4'] = c4_values(product) if product.c4_test
    h
  end

  def c1_values(product)
    h = {}
    h['checklist'] = Hash[%w(passing failing total).zip(checklist_status_values(product.product_tests.checklist_tests.first))]
    h['checklist']['not_started'] = h['checklist']['total'] = 1 if h['checklist']['total'] == 0 # manual entry displays as not started if not started
    h['cat1'] = Hash[%w(passing failing not_started total).zip(product_test_status_values(product.product_tests.measure_tests, 'C1Task'))]
    h['sums'] = h['cat1'].merge(h['checklist']) { |_key, old_val, new_val| old_val + new_val }
    h['href'] = "product_#{product.id}_c1"
    h['checklist']['display_name'] = 'Manual Entry'
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

  def cert_type_to_display_name(cert_type)
    case cert_type
    when 'C1' then 'C1 certification (Record and Export)'
    when 'C2' then 'C2 certification (Import and Calculate)'
    when 'C3' then 'C3 certification (Submission)'
    when 'C4' then 'C4 certification (Filtering)'
    end
  end

  # cert_hash (Hash) should contain 'sums' hash containing number of 'passing', 'failing', 'not_started', and 'total'
  # used for certification specifics popup on vendor show page
  def cert_status(cert_hash)
    if not_started_a_test?(cert_hash)
      'Not Complete'
    elsif cert_hash.sums.failing > 0
      'Failing'
    elsif cert_hash.sums.passing == cert_hash.sums.total
      'Passing'
    else
      'Not Complete'
    end
  end

  # returns true if a test type in the certification hash has no tests (total tests == 0)
  def not_started_a_test?(cert_hash)
    cert_hash.select { |_test_key, test_val| test_val.is_a?(Hash) && test_val.key?('display_name') }.each do |_test_key, test_val|
      return true if test_val.total == 0
    end
    false
  end

  # status should be 'Passing', 'Failing', or 'Not Complete'
  # used for each certification specifics popup on vendor show page
  def status_to_css_class(status)
    case status
    when 'Passing' then 'text-success'
    when 'Failing' then 'text-danger'
    else 'text-info'
    end
  end

  # displayed under each progress bar on vendor show page
  def status_to_display_text(status, cert_type, cert_hash)
    return 'not started' if cert_hash.sums.total == 0
    case status
    when 'Passing' then "#{cert_type} certified"
    when 'Failing' then "#{cert_hash.sums.failing} tests failing"
    else "#{cert_hash.sums.not_started} tests to go"
    end
  end
end
