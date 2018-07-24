include ProductsHelper

# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product selecting C4 testing$/) do
  measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
  bundle_id = Bundle.default._id
  @vendor = Vendor.create!(name: 'test_vendor_name')
  @product = @vendor.products.create!(name: 'test_product_name', c1_test: true, c4_test: true, measure_ids: measure_ids, bundle_id: bundle_id)
  product_params = { 'name' => 'params',
                     'version' => '',
                     'description' => '',
                     'randomize_patients' => '1',
                     'duplicate_patients' => '1',
                     'shift_patients' => '0',
                     'bundle_id' => bundle_id,
                     'measure_selection' => 'custom',
                     'c1_test' => '1',
                     'c2_test' => '0',
                     'c3_test' => '0',
                     'c4_test' => '1',
                     'measure_ids' => measure_ids }
  @product.update_with_measure_tests(product_params)
  wait_for_all_delayed_jobs_to_run
  @f_test1 = @product.product_tests.filtering_tests[0]
  @f_test2 = @product.product_tests.filtering_tests[1]
end

And(/^the user visits the product show page with the filter test tab selected$/) do
  html_id_for_tab(@product, 'FilteringTest')
  visit "/vendors/#{@vendor.id}/products/#{@product.id}##{html_id_for_tab(@product, 'FilteringTest')}"
end

And(/^the first filter task state has been set to ready$/) do
  @f_test1.state = :ready
  @f_test1.save!
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user is changed to an admin$/) do
  @user.add_role :admin
end

When(/^the user views the CAT 1 test for the first filter task$/) do
  find(:xpath, "//a[@href='/tasks/#{@f_test1.cat1_task.id}/test_executions/new']").click
end

When(/^the user views the CAT 3 test for the first filter task$/) do
  find(:xpath, "//a[@href='/tasks/#{@f_test1.cat3_task.id}/test_executions/new']").click
end

#   A N D   #

And(/^the user views the CAT 3 test from the CAT 1 page$/) do
  find(:xpath, "//a[@href='/tasks/#{@f_test1.cat3_task.id}/test_executions/new']").trigger('click')
end

And(/^the user has viewed the CAT 1 test for the first filter task$/) do
  wait_for_all_delayed_jobs_to_run
  steps %(
    When the user views the CAT 1 test for the first filter task
  )
end

And(/^the user views the Expected Result Patient List page$/) do
  find('a', text: 'View Expected Result').trigger('click')
end

# 'And the user uploads a CAT 1 zip file' included in step_definitions/measure_test.rb

# 'And the user uploads a CAT 3 XML file' included in step_definitions/measure_test.rb

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the CAT 1 test$/) do
  sleep(0.5)
  assert page.has_content?('a zip file of QRDA Category I documents')
end

Then(/^the user should see the CAT 3 test$/) do
  sleep(0.5)
  assert page.has_content?('a QRDA Category III XML document')
end

Then(/^the user should not see provider information$/) do
  page.assert_no_text 'Provider Name'
  page.assert_no_text 'Provider NPI'
  page.assert_no_text 'Provider TIN'
end

Then(/^the user should not see the View Expected Result option$/) do
  sleep(0.5)
  assert !page.has_content?('View Expected Result')
end

Then(/^the user should see a list of expected patients$/) do
  page.assert_text 'Expected Result Patient List'
  assert page.has_selector?('table tbody tr', count: @f_test1.filtered_patients.length), 'different count'
end

Then(/^the user should see a Total row$/) do
  page.assert_text 'Expected Result Patient List'
  assert page.has_selector?('table tfoot tr', count: 1), 'different count'
end

# 'Then the user should see a list of patients' included in step_definitions/record.rb

# 'Then the user should be able to download a CAT 1 zip file' included in step_definitions/measure_test.rb

# 'Then the user should see test results' included in step_definitions/measure_test.rb
