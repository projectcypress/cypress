
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

And(/^the user switches to c2 certification$/) do
  page.click_link 'start'
end

And(/^the user switches to c2 and c3 certification$/) do
  page.click_link 'start'
end

And(/^the product test state is set to ready$/) do
  ProductTest.all.each do |pt|
    pt.state = :ready
    pt.save!
  end
end

And(/^the product test state is not set to ready$/) do
  pt = ProductTest.first
  pt.state = :garbablargblarg
  pt.save!
end

And(/^the user uploads a CAT 1 zip file$/) do
  zip_path = File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip')
  page.attach_file('results', zip_path)
  page.find('#submit-upload').click
end

And(/^the user uploads a CAT 3 XML file$/) do
  xml_path = File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml')
  page.attach_file('results', xml_path)
  page.find('#submit-upload').click
end

And(/^the user uploads an invalid file$/) do
  invalid_file_path = File.join(Rails.root, 'app/assets/images/checkmark.svg')
  page.attach_file('results', invalid_file_path)
  page.find('#submit-upload').click
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the upload functionality for that product test$/) do
  page.assert_text @measure.name
  page.assert_text 'Download Test Deck'
end

Then(/^the user should only see the c1 execution page$/) do
  page.assert_text 'C1 certification'
  page.assert_no_text 'Switch to C2'
end

Then(/^the user should only see the c2 execution page$/) do
  page.assert_text 'C2 certification'
  page.assert_no_text 'Switch to C1'
end

Then(/^the user should see the c2 execution page$/) do
  page.assert_text 'C2 certification for'
  page.assert_no_text 'C1 certification for'
end

Then(/^the user should see the c2 and c3 execution page$/) do
  page.assert_text 'C2 and C3 certifications for'
  page.assert_no_text 'C1 and C3 certifications for'
end

Then(/^the user should be able to download a CAT 1 zip file$/) do
  page.assert_text 'Download QRDA Cat I (.zip)'
end

Then(/^the user should not be able to download a CAT 1 zip file$/) do
  page.assert_text 'is building test'
  page.assert_no_text 'Download QRDA Cat I (.zip)'
end

Then(/^the user should see test results$/) do
  assert_text 'Results'
end

Then(/^the user should see an error message saying the upload was invalid$/) do
  assert_text 'Invalid file upload'
end

#   A N D   #

And(/^the user should see no execution results$/) do
  page.assert_no_text 'Results'
end
