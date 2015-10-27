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
  @product = FactoryGirl.build(:product)
  steps %( When the user creates a product with name #{@product.name} for vendor #{@vendor.name} )
end

When(/^the user creates a product with name (.*) for vendor (.*)$/) do |product_name, vendor_name|
  steps %( When the user navigates to the create product page for vendor #{vendor_name} )
  page.fill_in 'Product Name', with: product_name
  page.find('label', text: 'Eligible Hospital').click
  page.click_button 'Create Product'
end

When(/^the user creates a product using appropriate information with eligible provider$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.fill_in 'Product Name', with: @product.name
  page.find('label', text: 'Eligible Provider').click
  page.click_button 'Create Product'
end

When(/^the user navigates to the create product page for vendor (.*)$/) do |vendor_name|
  visit('/')
  page.click_link vendor_name
  page.click_button '+ Add Product'
end

When(/^the user creates a product with no name$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product_no_name)
  page.fill_in 'Product Name', with: @product.name
  page.find('label', text: 'Eligible Hospital').click
  page.click_button 'Create Product'
end

When(/^the user creates two products with the same name$/) do
  @product = FactoryGirl.build(:product_static_name)
  steps %(
    When the user creates a product with name #{@product.name} for vendor #{@vendor.name}
    When the user creates a product with name #{@product.name} for vendor #{@vendor.name}
  )
end

When(/^the user creates a product with no ehr type$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.fill_in 'Product Name', with: @product.name
  # page.find('label', text: 'Eligible Hospital').click
  page.click_button 'Create Product'
end

When(/^the user cancels creating a product$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.click_button 'Cancel'
end

When(/^the user changes the name of the product$/) do
  page.click_button 'Edit'
  @product_other = FactoryGirl.build(:product)
  page.fill_in 'Product Name', with: @product_other.name
  page.click_button 'Update Product'
end

When(/^the user removes the product$/) do
  page.click_button 'Edit'
  page.click_button 'Remove Product'
  page.fill_in 'Remove Name', with: @product.name
  page.click_button 'Remove'
end

When(/^the user removes the product from the vendor page$/) do
  page.find("button[data-object-name=\"#{@product.name}\"]").click
  page.fill_in 'Remove Name', with: @product.name
  page.find('div.modal-footer').find('button', text: 'Remove').click
end

When(/^the user cancels removing the product$/) do
  page.click_button 'Edit'
  page.click_button 'Remove Product'
  page.find('div.modal-footer').find('button', text: 'Cancel').click
  page.click_button 'Cancel'
end

When(/^the user views the product$/) do
  page.click_link @product.name
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see a notification saying the product was created$/) do
  page.assert_text "Product '#{@product.name}' was created."
end

Then(/^the user should see an error message saying the product has no name$/) do
  page.assert_text "Name can't be blank"
end

Then(/^the user should see an error message saying the product name has been taken$/) do
  page.assert_text 'name was already taken'
end

Then(/^the user should see an error message saying the product has no ehr type$/) do
  page.assert_text "Ehr type can't be blank"
end

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
  page.assert_text @product.ehr_type
end
