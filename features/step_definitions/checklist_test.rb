
# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product selecting C1 testing and 5 measures$/) do
  @measures = Measure.all.sort_by { rand }.first(5)
  @vendor = Vendor.new(name: 'Vendor 1')
  @vendor.save!
  @product = @vendor.products.build(name: 'Product 1', c1_test: true, c2_test: false, c3_test: false, c4_test: false)
  @measures.each do |measure|
    @product.product_tests.build({ name: measure.name, measure_ids: [measure.id], bundle_id: measure.bundle_id }, MeasureTest)
  end
  @product.save!
end

And(/^the user views that product$/) do
  visit "/vendors/#{@vendor.id}/products/#{@product.id}"
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user generates a checklist test$/) do
  page.click_button 'Generate Test'
end

#   A N D   #

And(/^the user goes to perform the checklist test$/) do
  page.click_button 'Perform Inspection'
end

And(/^the user deletes the checklist test$/) do
  page.click_button 'Delete Visual Test'
  page.fill_in 'Remove Name', with: 'delete checklist'
  page.click_button 'Remove'
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should be able to perform the checklist test$/) do
  assert page.has_selector?("input[type = submit][value = 'Perform Inspection']")
end

Then(/^the user should see the checklist test$/) do
  assert_text('Manual Entry Checklist')
end

Then(/^the user be able to generate another checklist test$/) do
  assert_equal false, page.has_selector?("input[type = submit][value = 'Perform Inspection']")
  assert page.has_selector?("input[type = submit][value = 'Generate Test']")
end
