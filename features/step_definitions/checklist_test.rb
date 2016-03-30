
# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product selecting C1 testing with one measure$/) do
  @vendor = FactoryGirl.create(:vendor)
  @product = Product.new(vendor: @vendor, name: 'Product 1', c1_test: true, measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'],
                         bundle_id: '4fdb62e01d41c820f6000001')
  @product.product_tests.build({ name: 'test_for_measure_1a',
                                 measure_ids: ['40280381-4B9A-3825-014B-C1A59E160733'] }, MeasureTest)
  @product.save!
end

And(/^the user views that product$/) do
  visit vendor_product_path(@vendor, @product)
end

And(/^the user views the manual entry tab$/) do
  page.find("[href='#ChecklistTest']").click
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user generates a checklist test$/) do
  steps %( And the user views the manual entry tab )
  page.find("input[type = submit][value = 'Start Test']").click
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
  assert_text(APP_CONFIG['tests']['ChecklistTest']['description'])
end

Then(/^the user should see a button to revisit the checklist test$/) do
  assert page.has_selector?("input[type = submit][value = 'View Test']")
end

Then(/^the user should be able to generate another checklist test$/) do
  steps %( And the user views the manual entry tab )
  assert_equal false, page.has_selector?("input[type = submit][value = 'View Test']")
  assert page.has_selector?("input[type = submit][value = 'Start Test']")
end
