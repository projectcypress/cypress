require 'test_helper'

class XmlViewHelperTest < ActiveSupport::TestCase
  include XmlViewHelper
  include ActiveJob::TestHelper

  def setup
    drop_database
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    load_library_functions
    product_test = ProductTest.find('51703a883054cf84390000d3')
    task = product_test.tasks.create({}, C1Task)

    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_much_data_and_missing_template_ids.zip'))

    perform_enqueued_jobs do
      @te = task.execute(zip)
      @te.reload
    end
  end

  def test_get_error_mapping
    error_maps = get_error_mapping(@te)
    assert_equal 4, error_maps[0][:file_errors].collect(&:location).compact.count, 'should contain four locations for errors'
  end

  def test_popup_attributes_one_error
    error_maps = get_error_mapping(@te)
    errors = [error_maps[0][:file_errors][0]]
    title, button_text, message = popup_attributes(errors)

    assert_match 'Execution Error', title
    assert_match 'view error', button_text
    assert_no_match '<li', message
  end

  def test_popup_attributes_multiple_errors
    error_maps = get_error_mapping(@te)
    errors = error_maps[0][:file_errors]
    title, button_text, message = popup_attributes(errors)

    assert_match 'Execution Errors', title
    assert_match errors.count.to_s, title
    assert_match 'view errors', button_text
    assert_match errors.count.to_s, button_text
    assert_match '<li', message
  end
end
