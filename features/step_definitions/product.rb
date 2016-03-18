
# # # # # # # # # # #
#   H E L P E R S   #
# # # # # # # # # # #

def build_product
  Product.new(name: 'Product 1', measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'], bundle_id: '4fdb62e01d41c820f6000001')
end

# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product$/) do
  steps %(
    When the user creates a vendor with appropriate information
    When the user creates a product using appropriate information
  )
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user creates a product using appropriate information$/) do
  @product = build_product
  steps %( When the user creates a product with name #{@product.name} for vendor #{@vendor.name} )
end

When(/^the user creates a product with name (.*) for vendor (.*)$/) do |product_name, vendor_name|
  steps %( When the user navigates to the create product page for vendor #{vendor_name} )
  page.fill_in 'Name', with: product_name
  page.find('#product_c1_test').click
  page.find('#product_measure_selection_custom').click
  page.all('.sidebar a')[2].click
  page.all('input.measure-checkbox')[0].click
  page.click_button 'Add Product'
end

When(/^the user navigates to the create product page$/) do
  visit('/')
  page.click_link @vendor.name
  page.click_button 'Add Product'
end

When(/^the user navigates to the create product page for vendor (.*)$/) do |vendor_name|
  visit('/')
  page.click_link vendor_name
  page.click_button 'Add Product'
end

When(/^the user creates a product with no name$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product_no_name)
  page.fill_in 'Name', with: @product.name
  page.find('#product_c1_test').click
  page.find('#product_measure_selection_custom').click
  page.all('.sidebar a')[2].click
  page.all('input.measure-checkbox')[0].click
end

When(/^the user creates two products with the same name$/) do
  @product = FactoryGirl.build(:product_static_name)
  steps %(
    When the user creates a product with name #{@product.name} for vendor #{@vendor.name}
    When the user creates a product with name #{@product.name} for vendor #{@vendor.name}
  )
end

When(/^the user creates a product with no task type$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.fill_in 'Name', with: @product.name
  page.find('#product_measure_selection_custom').click
  page.all('.sidebar a')[2].click
  page.all('input.measure-checkbox')[0].click
end

When(/^the user fills out all product information but measures$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.fill_in 'Name', with: @product.name
  page.find('#product_measure_selection_custom').click
  page.find('#product_c1_test').click
end

# V V V Measure Selection V V V

When(/^the user creates a product with multiple measures from different groups$/) do
  steps %( When the user fills out all product information but measures )
  page.all('.sidebar a')[2].click
  page.find('input.measure-checkbox').click
  page.all('.sidebar a')[3].click
  page.find('input.measure-checkbox').click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a group of measures$/) do
  steps %( When the user fills out all product information but measures )
  page.find("[href='#Miscellaneous_div']").click
  page.find('input.measure_group_all').click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a measure then deselecting that measure$/) do
  steps %( When the user fills out all product information but measures )
  page.all('.sidebar a')[2].click
  page.all('input.measure-checkbox')[0].click
  page.all('input.measure-checkbox')[0].click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a group of measures then deselecting that group$/) do
  steps %( When the user fills out all product information but measures )
  page.find("[href='#Miscellaneous_div']").click
  page.find('input.measure_group_all').click
  page.find('input.measure_group_all').click
  page.click_button 'Add Product'
end

And(/^the user selects a group of measures but deselects one$/) do
  page.find("[href='#Miscellaneous_div']").click
  page.find('input.measure_group_all').click
  page.all('input.measure-checkbox')[0].click
end

# ^ ^ ^ Measure Selection ^ ^ ^

When(/^the user cancels creating a product$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.click_button 'Cancel'
end

When(/^the user changes the name of the product$/) do
  page.click_button 'Edit Product'
  @product_other = FactoryGirl.build(:product)
  page.fill_in 'Name', with: @product_other.name
  page.click_button 'Update Product'
end

When(/^the user removes the product$/) do
  page.click_button 'Edit Product'
  page.click_button 'Delete Product'
  page.fill_in 'Remove Name', with: @product.name
  page.click_button 'Remove', visible: true
end

When(/^the user removes the product from the vendor page$/) do
  page.click_button 'Edit Product'
  page.click_button 'Delete Product'
  page.fill_in 'Remove Name', with: @product.name
  page.find('div.modal-footer').find('button', text: 'Remove').click
end

When(/^the user cancels removing the product$/) do
  page.click_button 'Edit Product'
  page.click_button 'Delete Product'
  page.find('div.modal-footer').find('button', text: 'Cancel').click
  page.find('div.panel-footer').click_button 'Cancel'
end

When(/^the user views the product$/) do
  page.click_link @product.name
end

When(/^all measure tests have a state of ready$/) do
  ProductTest.all.each do |pt|
    pt.state = :ready
    pt.save!
  end
end

When(/^all measure tests do not have a state of ready$/) do
  pt = ProductTest.first
  pt.state = :nah_man_im_like_lightyears_away_from_bein_ready
  pt.save!
end

#   A N D   #

And(/^the user visits the product page$/) do
  visit "/vendors/#{Vendor.first.id}/products/#{Product.first.id}"
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see a notification saying the product was created$/) do
  page.assert_text "'#{@product.name}' was created."
end

Then(/^the user should not be able to create a product$/) do
  assert_equal true, page.has_button?('Add Product', disabled: true)
end

Then(/^the user should see an error message saying the product name has been taken$/) do
  page.assert_text 'name was already taken'
end

Then(/^the user should see an error message saying the product must certify to C1 or C2$/) do
  page.assert_text 'Must certify to at least C1 or C2'
end

Then(/^the user should see an error message saying the product must have at least one measure$/) do
  page.assert_text 'Must select measures'
end

Then(/^the default bundle should be pre-selected$/) do
  Bundle.all.each do |bundle|
    if bundle.active
      assert page.has_checked_field?(bundle.title), 'default bundle should be pre-selected'
    else
      assert page.has_unchecked_field?(bundle.title), 'non-default bundle should not be selected'
    end
  end
end

# V V V Measure Selection V V V

Then(/^the group of measures should no longer be selected$/) do
  page.has_unchecked_field?('input.measure_group_all')
end

# ^ ^ ^ Measure Selection ^ ^ ^

Then(/^the user should not see the product$/) do
  page.assert_text @vendor.name
  page.assert_no_text @product.name
end

Then(/^the user should see an notification saying the product was edited$/) do
  page.assert_text 'was edited'
end

Then(/^the user should see a notification saying the product was removed$/) do
  page.assert_text 'was removed'
end

Then(/^the user should still see the product$/) do
  page.assert_text @product.name
end

Then(/^the user should see the product information$/) do
  page.assert_text @product.name
  page.assert_text @vendor.name
end

Then(/^the user should be able to download all patients$/) do
  page.assert_text 'Download All Patients'
end

Then(/^the user should not be able to download all patients$/) do
  page.assert_no_text 'Download All Patients'
  page.assert_text 'records are being built'
end

Then(/^the user should be able to download the PDF$/) do
  page.click_button 'Download Report'
  assert_equal 'application/pdf', page.response_headers['Content-Type']
end
