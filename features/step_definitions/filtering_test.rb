
# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product selecting C4 testing$/) do
  @vendor = Vendor.create!(name: 'test_vendor_name')
  @product = @vendor.products.create!(name: 'test_product_name', c1_test: true, c4_test: true)
  @m_test = @product.product_tests.create!({ name: 'Hearing Screening Prior To Hospital Discharge', cms_id: 'CMS31v3',
                                             measure_ids: ['40280381-43DB-D64C-0144-5571970A2685']
                                           }, MeasureTest)
  @f_test_1 = @product.product_tests.create!({ name: 'Filter Test 1', cms_id: 'CMS31v3', measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'],
                                               options: { filters: { filt1: ['val1'], filt2: ['val2'] } }
                                             }, FilteringTest)
  @f_test_2 = @product.product_tests.create!({ name: 'Filter Test 2', cms_id: 'CMS31v3', measure_ids: ['40280381-43DB-D64C-0144-5571970A2685'],
                                               options: { filters: { filt3: ['val2'], filt4: ['val4'] } }
                                             }, FilteringTest)
end

And(/^the user visits the product show page with the filter test tab selected$/) do
  visit "/vendors/#{@vendor.id}/products/#{@product.id}#FilteringTest"
end

And(/^the first filter task state has been set to ready$/) do
  @f_test_1.state = :ready
  @f_test_1.save!
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user views the CAT 1 test for the first filter task$/) do
  find(:xpath, "//a[@href='/tasks/#{@f_test_1.cat1_task.id}/test_executions/new']").click
end

When(/^the user views the CAT 3 test for the first filter task$/) do
  find(:xpath, "//a[@href='/tasks/#{@f_test_1.cat3_task.id}/test_executions/new']").click
end

#   A N D   #

And(/^the user views the CAT 3 test from the CAT 1 page$/) do
  find(:xpath, "//a[@href='/tasks/#{@f_test_1.cat3_task.id}/test_executions/new']").click
end

# 'And the user uploads a CAT 1 zip file' included in step_definitions/measure_test.rb

# 'And the user uploads a CAT 3 XML file' included in step_definitions/measure_test.rb

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the CAT 1 test$/) do
  assert page.has_content?('Upload your CAT 1 zip file')
end

Then(/^the user should see the CAT 3 test$/) do
  sleep(0.5)
  assert page.has_content?('Upload your CAT 3 XML file')
end

# 'Then the user should be able to download a CAT 1 zip file' included in step_definitions/measure_test.rb

# 'Then the user should see test results' included in step_definitions/measure_test.rb
