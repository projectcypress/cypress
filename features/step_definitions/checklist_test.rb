
# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product selecting C1 testing and 5 measures$/) do
  @vendor = FactoryGirl.create(:vendor)
  @product = Product.new
  @product.vendor = @vendor
  @product.name = 'Product 1'
  @product.c1_test = true
  @product.product_tests.build({ name: 'test_for_measure_1a',
                                 measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'],
                                 bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
  @product.save!
end

And(/^the user views that product$/) do
  visit "/vendors/#{@vendor.id}/products/#{@product.id}"
end

And(/^the user views the manual entry tab$/) do
  page.execute_script("$('#ChecklistTest').click()")
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user generates a checklist test$/) do
  page.execute_script("$('#ChecklistTest').click()")
  find_button('Start Test').trigger('click')
end

#   A N D   #

And(/^the user views that checklist test$/) do
  page.find("input[type = submit][value = 'View Test']").click
end

And(/^the user deletes the checklist test$/) do
  page.click_button 'Delete Visual Test'
  page.fill_in 'Remove Name', with: 'delete checklist'
  page.click_button 'Remove'
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the checklist test$/) do
  assert_text('Check source data scriteria to validate the EHR system for C1 certification.')
end

Then(/^the user should see a button to revisit the checklist test$/) do
  assert page.has_selector?("input[type = submit][value = 'View Test']")
end

Then(/^the user should be able to generate another checklist test$/) do
  assert_equal false, page.has_selector?("input[type = submit][value = 'View Test']")
  assert page.has_selector?("input[type = submit][value = 'Start Test']")
end
