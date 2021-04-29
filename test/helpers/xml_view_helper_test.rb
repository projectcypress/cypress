# frozen_string_literal: true

require 'test_helper'

class XmlViewHelperTest < ActiveSupport::TestCase
  include XmlViewHelper
  include ActiveJob::TestHelper

  def setup
    user = FactoryBot.create(:vendor_user)
    product_test = FactoryBot.create(:cv_product_test_static_result)
    product_test.product.c1_test = true
    product_test.product.c3_test = true
    task = product_test.tasks.create({}, C1Task)
    product_test.tasks.create({}, C3Cat1Task)
    zip = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'ep_qrda_test_wrong_templates.zip'))

    perform_enqueued_jobs do
      @te = task.execute(zip, user)
      @te.reload
    end
  end

  def test_collected_errors
    errs = Cypress::ErrorCollector.collected_errors(@te)
    assert_equal 0, errs.nonfile.count
    assert_equal 1, errs.files.keys.count, 'should contain one file with errors'
    assert_equal %w[Errors Warnings], errs.files['0_Dental_Peds_A.xml'].keys, 'should contain right error keys for each file'
  end

  def test_popup_attributes_multiple_errors
    errs = Cypress::ErrorCollector.collected_errors(@te)
    error = errs.files['0_Dental_Peds_A.xml']['Errors'].execution_errors
    title, button_text, _message = popup_attributes(error)
    assert_match 'Execution Errors (2)', title
    assert_match error.count.to_s, title
    assert_match 'view errors (2)', button_text
    assert_match error.count.to_s, button_text
  end

  def test_popup_attributes_one_error
    errs = Cypress::ErrorCollector.collected_errors(@te)
    error = [errs.files['0_Dental_Peds_A.xml']['Errors'].execution_errors.first] # get just one error
    title, button_text, message = popup_attributes(error)

    assert_match 'Execution Error', title
    assert_match 'view error', button_text
    assert_no_match '<li', message
  end
end
