
# # # # # # # # # # #
#   H E L P E R S   #
# # # # # # # # # # #

def collection_fixtures(*collections)
  collections.each do |collection|
    Mongoid.default_client[collection].drop
    Dir.glob(File.join(Rails.root, 'test', 'fixtures', collection, '*.json')).each do |json_fixture_file|
      fixture_json = JSON.parse(File.read(json_fixture_file), max_nesting: 250)
      map_bson_ids(fixture_json)
      Mongoid.default_client[collection].insert_one(fixture_json)
    end
  end
end

def value_or_bson(v)
  if v.is_a? Hash
    if v['$oid']
      BSON::ObjectId.from_string(v['$oid'])
    else
      map_bson_ids(v)
    end
  else
    v
  end
end

def map_bson_ids(json)
  json.each_pair do |k, v|
    if v.is_a? Hash
      json[k] = value_or_bson(v)
    elsif k == 'create_at' || k == 'updated_at'
      json[k] = Time.at.utc(v)
    end
  end
  json
end

def build_product
  Product.new(name: 'Product 1', measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'])
end

Before do
  collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
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
  page.find('#Asthma > div.checkbox').click
  page.click_button 'Add Product'
end

When(/^the user navigates to the create product page for vendor (.*)$/) do |vendor_name|
  visit('/')
  page.click_link vendor_name
  page.click_button '+ Add Product'
end

When(/^the user creates a product with no name$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product_no_name)
  page.fill_in 'Name', with: @product.name
  page.find('#product_c1_test').click
  page.find('#Asthma').click
  page.click_button 'Add Product'
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
  page.find('#Asthma').click
  page.click_button 'Add Product'
end

When(/^the user fills out all product information but measures$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.fill_in 'Name', with: @product.name
  page.find('#product_c1_test').click
end

When(/^the user creates a product without selecting a measure$/) do
  steps %( When the user fills out all product information but measures )
  page.click_button 'Add Product'
end

# V V V Measure Selection V V V

When(/^the user creates a product with multiple measures from different groups$/) do
  steps %( When the user fills out all product information but measures )
  page.find('#Asthma').click
  click_link('Behavioral Health Adult (EP)')
  page.find('#Behavioral_Health_Adult').click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a group of measures$/) do
  steps %( When the user fills out all product information but measures )
  click_link('Miscellaneous (EH)')
  page.find('#Miscellaneous_group').click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a measure then deselecting that measure$/) do
  steps %( When the user fills out all product information but measures )
  page.find('#Asthma').click
  page.find('#Asthma').click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a group of measures then deselecting that group$/) do
  steps %( When the user fills out all product information but measures )
  click_link('Miscellaneous (EH)')
  page.find('#Miscellaneous_group').click
  page.find('#Miscellaneous_group').click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a measure then deselecting from selected measures$/) do
  steps %( When the user fills out all product information but measures )
  page.check('Asthma Assessment')
  page.find('.selected-measure-list').uncheck('Asthma Assessment')
  page.click_button 'Add Product'
end

And(/^the user selects a group of measures but deselects one$/) do
  click_link('Miscellaneous (EH)')
  page.find('#Miscellaneous_group').click
  page.find('.measure_group', visible: true).uncheck('Aspirin Prescribed at Discharge')
end

And(/^the user selects a group of measures but deselects one from selected measures$/) do
  click_link('Miscellaneous (EH)')
  page.find('#Miscellaneous_group').click
  page.find('.selected-measure-list').uncheck('Aspirin Prescribed at Discharge')
end

# ^ ^ ^ Measure Selection ^ ^ ^

When(/^the user creates a product with no name and selects measures$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product_no_name)
  page.fill_in 'Name', with: @product.name
  page.find('#product_c1_test').click
  click_link('Miscellaneous (EH)')
  page.find('#Miscellaneous_group').click
  page.click_button 'Add Product'
end

When(/^the user cancels creating a product$/) do
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  @product = FactoryGirl.build(:product)
  page.click_button 'Cancel'
end

When(/^the user changes the name of the product$/) do
  page.click_button 'Edit'
  @product_other = FactoryGirl.build(:product)
  page.fill_in 'Name', with: @product_other.name
  page.click_button 'Update Product'
end

When(/^the user removes the product$/) do
  page.click_button 'Edit'
  page.click_button 'Delete Product'
  page.fill_in 'Remove Name', with: @product.name
  page.click_button 'Remove', visible: true
end

When(/^the user removes the product from the vendor page$/) do
  page.find("button[data-object-name=\"#{@product.name}\"]").click
  page.fill_in 'Remove Name', with: @product.name
  page.find('div.modal-footer').find('button', text: 'Remove').click
end

When(/^the user cancels removing the product$/) do
  page.click_button 'Edit'
  page.click_button 'Delete Product'
  page.find('div.modal-footer').find('button', text: 'Cancel').click
  page.find('div.panel-footer').click_button 'Cancel'
end

When(/^the user views the product$/) do
  page.click_link @product.name
end

When(/^the user downloads all patients$/) do
  steps %( When the user views the product )
  page.click_button 'Download All Patients (.zip)'
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see a notification saying the product was created$/) do
  page.assert_text "Product '#{@product.name}' was created."
end

Then(/^the user should see an error message saying the product has no name$/) do
  page.assert_text "can't be blank"
end

Then(/^the user should see an error message saying the product name has been taken$/) do
  page.assert_text 'name was already taken'
end

Then(/^the user should see an error message saying the product must have at least one task type$/) do
  page.assert_text 'must include at least one certification test'
end

Then(/^the user should see an error message saying the product must have at least one measure$/) do
  page.assert_text 'must specify least one measure for testing'
end

# V V V Measure Selection V V V

Then(/^the group of measures should no longer be selected$/) do
  page.has_unchecked_field?('#Miscellaneous_group')
end

# ^ ^ ^ Measure Selection ^ ^ ^

Then(/^there should be no product tests in the database$/) do
  assert_equal 0, ProductTest.all.count
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
end

Then(/^the total test deck should be downloaded$/) do
  file_name = "Full_Test_Deck_#{Product.all.first.id}.zip"
  assert page.driver.response_headers['Content-Disposition'].include?("filename=\"#{file_name}\"")
end
