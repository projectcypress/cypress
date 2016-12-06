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
    product_test.product.c1_test = true
    task = product_test.tasks.create({}, C1Task)

    zip = File.new(File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_too_much_data_and_missing_template_ids.zip'))

    perform_enqueued_jobs do
      @te = task.execute(zip)
      @te.reload
    end
  end

  def test_collected_errors
    errs = collected_errors(@te)
    assert_equal 0, errs.nonfile.count
    assert_equal 4, errs.files.keys.count, 'should contain four files with errors'
    assert_equal ['QRDA', 'Reporting', 'Submission', 'CMS Warnings', 'Other Warnings'], errs.files['0_Dental_Peds_A.xml'].keys, 'should contain right error keys for each file'
  end

  def test_popup_attributes_multiple_errors
    errs = collected_errors(@te)
    error = errs.files['0_Dental_Peds_A.xml']['QRDA'].execution_errors
    title, button_text, message = popup_attributes(error)

    assert_match 'Execution Errors', title
    assert_match error.count.to_s, title
    assert_match 'view errors', button_text
    assert_match error.count.to_s, button_text
    assert_match '<li', message
  end

  def test_popup_attributes_one_error
    errs = collected_errors(@te)
    error = [errs.files['3_GP_Peds_C.xml']['QRDA'].execution_errors.first] # get just one error
    title, button_text, message = popup_attributes(error)

    assert_match 'Execution Error', title
    assert_match 'view error', button_text
    assert_no_match '<li', message
  end
end
