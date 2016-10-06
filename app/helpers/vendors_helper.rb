include Cypress::ProductStatusValues

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

  # status should be 'Passing', 'Failing', or 'Not Complete'
  # used for each certification status on vendor show page
  def status_to_css_classes(status)
    classes = {}

    case status
    when 'passing'
      classes['cell'] = 'status-passing'
      classes['icon'] = 'fa-check'
      classes['text'] = 'text-success'
    when 'failing'
      classes['cell'] = 'status-failing'
      classes['icon'] = 'fa-times'
      classes['text'] = 'text-danger'
    when 'errored'
      classes['cell'] = 'status-errored'
      classes['icon'] = 'fa-exclamation'
      classes['text'] = 'text-warning'
    else
      classes['cell'] = 'status-not-started'
      classes['icon'] = 'fa-circle-o'
      classes['text'] = 'text-info'
    end

    classes
  end

  def vendor_statuses(vendor)
    h = {}
    h['passing'] = vendor.products_passing_count
    h['failing'] = vendor.products_failing_count
    h['errored'] = vendor.products_errored_count
    h['incomplete'] = vendor.products_incomplete_count
    h['total'] = vendor.products.count
    h
  end
end
