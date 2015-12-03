
# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has selected a measure$/) do
  @measure = Measure.all.first
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user creates a product with tasks (.*)$/) do |tasks|
  @product = Product.new
  @product.vendor = @vendor
  @product.name = 'Product 1'
  tasks = tasks.split(', ')
  @product.c1_test = tasks.include? 'c1'
  @product.c2_test = tasks.include? 'c2'
  @product.c3_test = tasks.include? 'c3'
  @product.c4_test = tasks.include? 'c4'
  @product.product_tests.build({ name: @measure.name, measure_ids: [@measure.id], bundle_id: @measure.bundle_id }, MeasureTest)
  @product_test = @product.product_tests.first
  @product.save!
end

#   A N D   #

And(/^the user views a product test for that product$/) do
  visit "/products/#{@product.id}/product_tests/#{@product_test.id}"
end

And(/^the user downloads the CAT 1 zip file$/) do
  page.click_button 'Download CAT 1 (.zip)'
end

And(/^the user uploads a CAT 1 zip file$/) do
  zip_path = File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip')
  page.find('.fileinput > .form-control').click
  page.attach_file(page.find('#results').value, zip_path)
  page.click_button('Upload and run test')
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the upload functionality for that product test$/) do
  page.assert_text @measure.name
  page.assert_text '[1] Download Test Deck'
end

Then(/^the user should see only the CAT 1 upload for c1$/) do
  page.assert_text '[2] Upload for C1'
  page.assert_no_text 'CAT 3 (C2)'
  page.assert_no_text 'CAT 3 (C2 and C3)'
end

Then(/^the user should see only the CAT 3 upload for c2$/) do
  page.assert_text '[2] Upload for C2'
  page.assert_no_text 'CAT 1 (C1)'
  page.assert_no_text 'CAT 1 (C1 and C3)'
end

Then(/^the user should see CAT 1 and CAT 3 tabs for c1 and c2$/) do
  page.assert_text '[2] Upload for C1'
  page.click_link 'CAT 3 (C2)'
  page.assert_text '[2] Upload for C2'
end

Then(/^the user should see CAT 1 and CAT 3 tabs for c1, c2, and c3$/)do
  page.assert_text '[2] Upload for C1 and C3'
  page.click_link 'CAT 3 (C2 and C3)'
  page.assert_text '[2] Upload for C2 and C3'
end

Then(/^the CAT 1 zip file should be downloaded$/) do
  file_name = "Test_#{@product_test.id}._qrda.zip"
  assert page.driver.response_headers['Content-Disposition'].include?("filename=\"#{file_name}\"")
  assert_text 'currently no test results to be displayed'
end

Then(/^the user should see test results$/) do
  assert_no_text 'currently no test results to be displayed'
end
