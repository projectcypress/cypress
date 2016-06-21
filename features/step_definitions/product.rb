
# # # # # # # # # # #
#   H E L P E R S   #
# # # # # # # # # # #

def build_product
  Product.new(name: 'Product 1', measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'], bundle_id: '4fdb62e01d41c820f6000001')
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
  page.find('#product_c2_test').click
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
  page.find('#product_c2_test').click
end

# V V V Measure Selection V V V

When(/^the user creates a product with multiple measures from different groups$/) do
  steps %( When the user fills out all product information but measures )
  page.all('.sidebar a')[2].click
  page.all('input.measure-checkbox')[0].click
  page.all('.sidebar a')[3].click
  page.all('input.measure-checkbox')[0].click
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
  page.click_link @product.name
  page.click_button 'Edit Product'
  @product_other = FactoryGirl.build(:product)
  page.fill_in 'Name', with: @product_other.name
  page.click_button 'Update Product'
end

When(/^the user removes the product$/) do
  page.click_link @product.name
  page.click_button 'Edit Product'
  page.click_button 'Delete Product'
  page.fill_in 'Remove Name', with: @product.name
  page.click_button 'Remove', visible: true
end

When(/^the user removes the product from the vendor page$/) do
  page.click_link @product.name
  page.click_button 'Edit Product'
  page.click_button 'Delete Product'
  page.fill_in 'Remove Name', with: @product.name
  page.find('div.modal-footer').find('button', text: 'Remove').click
end

When(/^the user cancels removing the product$/) do
  page.click_link @product.name
  page.click_button 'Edit Product'
  page.click_button 'Delete Product'
  page.find('div.modal-footer').find('button', text: 'Cancel').click
  page.find('div.panel-footer').click_button 'Cancel'
end

When(/^the user views the product$/) do
  page.click_link @product.name
end

When(/^all product tests have a state of ready$/) do
  ProductTest.all.each do |pt|
    pt.state = :ready
    pt.save!
  end
end

When(/^all product tests do not have a state of ready$/) do
  pt = ProductTest.first
  pt.state = :nah_man_im_like_lightyears_away_from_bein_ready
  pt.save!
end

When(/^the user visits the product page$/) do
  product = Product.first
  visit vendor_product_path(product.vendor, product)
end

When(/^the user switches to the filtering test tab$/) do
  page.click_link 'CQM Filtering Test'
end

When(/^the user adds a product test$/) do
  # measure to add
  measure_id = '40280381-43DB-D64C-0144-5571970A2685'
  product = Product.first
  product.measure_ids << measure_id
  product.save!
  product_test = product.product_tests.build({ name: "measure test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
  product_test.save!
  task = product_test.tasks.build({}, C1Task)
  task.save!
end

And(/^filtering tests are added to product$/) do
  product = Product.first
  product.c4_test = true
  product.save!
  product.add_filtering_tests
end

#   A N D   #

# product test number the number of product test (1 indexed) for upload in order of most recently created
And(/^the user uploads a cat I document to product test (.*)$/) do |product_test_number|
  html_id = td_div_id_for_cat1_task_for_product_test(product_test_number)
  attach_zip_to_multi_upload(html_id)
end

And(/^the user adds cat I tasks to all product tests$/) do
  product = Product.first
  product.c1_test = true
  product.save!
  product.product_tests.measure_tests.each do |pt|
    task = pt.tasks.build({ product_test: pt }, C1Task)
    task.save!
  end
end

And(/^the user uploads a cat III document to product test (.*)$/) do |product_test_number|
  html_id = td_div_id_for_cat3_task_for_product_test(product_test_number)
  attach_xml_to_multi_upload(html_id)
end

And(/^the user uploads a cat I document to filtering test (.*)$/) do |filtering_test_number|
  html_id = td_div_id_for_cat1_task_for_filtering_test(filtering_test_number)
  attach_zip_to_multi_upload(html_id)
end

And(/^the user uploads a cat III document to filtering test (.*)$/) do |filtering_test_number|
  html_id = td_div_id_for_cat3_task_for_filtering_test(filtering_test_number)
  attach_xml_to_multi_upload(html_id)
end

# product test number the number of product test (1 indexed) for upload in order of most recently created
def td_div_id_for_cat1_task_for_product_test(product_test_number)
  product_test = Product.first.product_tests.measure_tests.sort { |x, y| x.created_at <=> y.created_at }[product_test_number.to_i - 1]
  task = product_test.tasks.c1_task
  "#wrapper-task-id-#{task.id.to_s}"
end

def td_div_id_for_cat3_task_for_product_test(product_test_number)
  product_test = Product.first.product_tests.measure_tests.sort { |x, y| x.created_at <=> y.created_at }[product_test_number.to_i - 1]
  task = product_test.tasks.c2_task
  "#wrapper-task-id-#{task.id.to_s}"
end

def td_div_id_for_cat1_task_for_filtering_test(filtering_test_number)
  filtering_test = Product.first.product_tests.filtering_tests.sort { |x, y| x.created_at <=> y.created_at }[filtering_test_number.to_i - 1]
  task = filtering_test.tasks.cat1_filter_task
  "#wrapper-task-id-#{task.id.to_s}"
end

def td_div_id_for_cat3_task_for_filtering_test(filtering_test_number)
  filtering_test = Product.first.product_tests.filtering_tests.sort { |x, y| x.created_at <=> y.created_at }[filtering_test_number.to_i - 1]
  task = filtering_test.tasks.cat3_filter_task
  "#wrapper-task-id-#{task.id.to_s}"
end

def attach_zip_to_multi_upload(html_id)
  show_hidden_upload_field(html_id)

  # attach zip file to multi-upload field
  zip_path = File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip')
  page.find(html_id).attach_file('test_execution[results]', zip_path, visible: false)
end

def attach_xml_to_multi_upload(html_id)
  show_hidden_upload_field(html_id)

  # attach zip file to multi-upload field
  xml_path = File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml')
  page.find(html_id).attach_file('test_execution[results]', xml_path, visible: false)
end

# show input file upload html element. this is a known issue with capybara. capybara is unable to find inputs with surrounding <label> tags
def show_hidden_upload_field(html_id)
  script = "$('#{html_id}').find('input.multi-upload-field').removeClass('hidden').css({display: 'block'})"
  page.execute_script(script)
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see a notification saying the product was created$/) do
  page.assert_text "'#{@product.name}' was created."
end

Then(/^the user should not be able to create a product$/) do
  page.click_button 'Add Product'
  page.assert_no_text "'#{@product.name}' was created."
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

Then(/^the user should see a notification saying the product was edited$/) do
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

Then(/^the user should be able to view the report$/) do
  page.click_button 'Download Report'
  page.assert_text 'Report Summary'
end

Then(/^the user should see a cat I test testing for product test (.*)$/) do |product_test_number|
  html_id = td_div_id_for_cat1_task_for_product_test(product_test_number)
  html_elem = page.find(html_id)
  html_elem.assert_text 'testing...'
end

Then(/^the user should see a cat III test testing for product test (.*)$/) do |product_test_number|
  html_id = td_div_id_for_cat3_task_for_product_test(product_test_number)
  html_elem = page.find(html_id)
  html_elem.assert_text 'testing...'
end

Then(/^the user should see a cat I test testing for filtering test (.*)$/) do |filtering_test_number|
  html_id = td_div_id_for_cat1_task_for_filtering_test(filtering_test_number)
  html_elem = page.find(html_id)
  html_elem.assert_text 'testing...'
end

Then(/^the user should see a cat III test testing for filtering test (.*)$/) do |filtering_test_number|
  html_id = td_div_id_for_cat3_task_for_filtering_test(filtering_test_number)
  html_elem = page.find(html_id)
  html_elem.assert_text 'testing...'
end
