module VendorsHelper
  include Cypress::ProductStatusValues

  def formatted_vendor_address(vendor)
    address = [vendor.address, vendor.state, vendor.zip].delete_if { |x| x == '' }
    address.count.positive? ? address.join(', ') : nil
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

  # return value is nested hash structured like this:
  #   { certification_type: { product_test_type: { passing: #, failing: #, not_started: #, total: # } } }
  def get_cvu_status_values(product)
    Rails.cache.fetch("#{product.cache_key}/cvu_status_values") do
      h = {}
      h['EP_Measure'] = ep_status_values(product)
      h['EH_Measure'] = eh_status_values(product)
      h['CMS_Program'] = cms_status_values(product)
      h
    end
  end

  # status should be 'Passing', 'Failing', or 'Not Complete'
  # used for each certification status on vendor show page
  def status_to_css_classes(status)
    case status
    when 'passing'
      { 'cell' => 'status-passing', 'icon' => 'check', 'type' => 'fas', 'text' => 'text-success' }
    when 'failing'
      { 'cell' => 'status-failing', 'icon' => 'times', 'type' => 'fas', 'text' => 'text-danger' }
    when 'errored'
      { 'cell' => 'status-errored', 'icon' => 'exclamation', 'type' => 'fas', 'text' => 'text-warning' }
    else
      { 'cell' => 'status-not-started', 'icon' => 'circle', 'type' => 'far', 'text' => 'text-info' }
    end
  end

  def vendor_statuses(vendor)
    h = {}
    h['passing'] = vendor.products_passing_count
    h['failing'] = vendor.products_failing_count
    h['errored'] = vendor.products_errored_count
    h['incomplete'] = vendor.products_incomplete_count
    h['total'] = h['passing'] + h['failing'] + h['errored'] + h['incomplete']
    h
  end
end
