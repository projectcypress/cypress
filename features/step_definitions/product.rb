include ProductsHelper

# # # # # # # # # # #
#   H E L P E R S   #
# # # # # # # # # # #

def build_product
  Product.new(name: 'Product 1', measure_ids: ['40280381-4BE2-53B3-014C-0F589C1A1C39'], bundle_id: '4fdb62e01d41c820f6000001')
end

# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

Given(/^the user is signed in as a non admin$/) do
  User.all.destroy # FIXME: there's gotta be a better way
  @user = FactoryGirl.create(:user)
  @user.approved = true
  login_as @user, :scope => :user
  steps %( Given the user is on the sign in page )
end

Given(/^the user is owner of the vendor$/) do
  @user.add_role(:owner, @vendor)
end

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

# certs argument stands for certifications and should be a comma separated list of some of these values: c1, c2, c3, c4
When(/^a user creates a product with (.*) certifications and visits that product page$/) do |certs|
  certs = certs.split(', ')
  steps %( When the user navigates to the create product page for vendor #{@vendor.name} )
  product_name = "my product #{rand}"
  page.fill_in 'Name', with: product_name
  page.find('#product_c1_test').click if certs.include? 'c1'
  page.find('#product_c2_test').click if certs.include? 'c2'
  page.find('#product_c3_test').click if certs.include? 'c3'
  page.find('#product_c4_test').click if certs.include? 'c4'
  page.find('#product_measure_selection_custom').click
  page.all('#measure_tabs .ui-tabs-nav a')[1].click # should tab for "Behavioral Health Adult"
  page.all('input.measure-checkbox')[1].click # should get measure for "Depression Remission at Twelve Months"
  page.click_button 'Add Product'
  page.click_link product_name
  # By running find_by after we have already clicked a link to the same product we are trying to find,
  # we are able to avoid a race condition where the product is not yet created when we run the find_by.
  @product = Product.find_by(name: product_name)
end

When(/^the user creates a product using appropriate information$/) do
  @product = build_product
  steps %( When the user creates a product with name #{@product.name} for vendor #{@vendor.name} )
end

When(/^the user creates a product with name (.*) for vendor (.*)$/) do |product_name, vendor_name|
  steps %( When the user navigates to the create product page for vendor #{vendor_name} )
  page.fill_in 'Name', with: product_name
  page.find('#product_c2_test').click
  page.find('#product_measure_selection_custom').click
  page.all('#measure_tabs .ui-tabs-nav a')[2].click
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
  page.all('#measure_tabs .ui-tabs-nav a')[2].click
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
  page.all('#measure_tabs .ui-tabs-nav a')[2].click
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
  page.all('#measure_tabs .ui-tabs-nav a')[2].click
  page.all('input.measure-checkbox')[0].click
  page.all('#measure_tabs .ui-tabs-nav a')[3].click
  page.all('input.measure-checkbox')[0].click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a group of measures$/) do
  steps %( When the user fills out all product information but measures )
  page.find("[href='#Miscellaneous_div']").click
  page.find('input.measure-group-all').click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a measure then deselecting that measure$/) do
  steps %( When the user fills out all product information but measures )
  page.all('#measure_tabs .ui-tabs-nav a')[2].click
  page.all('input.measure-checkbox')[0].click
  page.all('input.measure-checkbox')[0].click
  page.click_button 'Add Product'
end

When(/^the user creates a product with selecting a group of measures then deselecting that group$/) do
  steps %( When the user fills out all product information but measures )
  page.find("[href='#Miscellaneous_div']").click
  page.find('input.measure-group-all').click
  page.find('input.measure-group-all').click
  page.click_button 'Add Product'
end

And(/^the user selects a group of measures but deselects one$/) do
  page.find("[href='#Miscellaneous_div']").click
  page.find('input.measure-group-all').click
  page.all('input.measure-checkbox')[0].click
end

And(/^the user chooses the custom measure option$/) do
  # Click the custom measure option radio button
  page.find('#product_measure_selection_custom').click
end

And(/^the user manually selects all measures$/) do
  # Clear the measure filter field
  page.fill_in 'Type to filter by measure', with: ''
  # We are selecting the first checkbox in every tab. This works because
  # every measure either has a "select all" button at the top or only has
  # 1 measure, so this will always select all measures.
  page.all('#measure_tabs .ui-tabs-nav a').each do |tab|
    tab.click
    page.all('#measure_tabs fieldset .checkbox input').first.set(true)
  end
end

And(/^the user types "([^"]*)" into the measure filter box$/) do |filter_text|
  page.fill_in 'Type to filter by measure', with: filter_text
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
  page.click_button 'Edit Product'
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
  pt = ProductTest.find_by(cms_id: 'CMS155v1')
  pt.state = :nah_man_im_like_lightyears_away_from_bein_ready
  pt.save!
end

When(/^the user visits the product page$/) do
  product = @product
  visit vendor_product_path(product.vendor, product)
end

When(/^the user adds a product test$/) do
  # measure to add
  measure_id = '40280381-43DB-D64C-0144-5571970A2685'
  product = @product
  product.measure_ids << measure_id
  product.save!
  product_test = product.product_tests.build({ name: "measure test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
  product_test.save!
  task = product_test.tasks.build({}, C1Task)
  task.save!
end

And(/^filtering tests are added to product$/) do
  product = @product
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
  product = @product
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

When(/^all test executions for product test (.*) have the state of (.*)$/) do |product_test_number, execution_state|
  give_all_test_executions_state(nth_measure_test(product_test_number), execution_state)
end

When(/^all test executions for filtering test (.*) have the state of (.*)$/) do |filtering_test_number, execution_state|
  give_all_test_executions_state(nth_filtering_test(filtering_test_number), execution_state)
end

def give_all_test_executions_state(product_test, execution_state)
  product_test.tasks.each do |task|
    task.test_executions.each do |execution|
      execution.state = execution_state.parameterize.underscore.to_sym
      execution.save!
    end
  end
end

When(/^the user switches to the manual entry tab$/) do
  page.find(:xpath, "//a[@href=\"##{html_id_for_tab(@product, 'ChecklistTest')}\"]").click
end

When(/^the user switches to the c1 measure test tab$/) do
  page.find(:xpath, "//a[@href=\"##{html_id_for_tab(@product, 'MeasureTest', true)}\"]").click
end

When(/^the user switches to the c2 measure test tab$/) do
  page.find(:xpath, "//a[@href=\"##{html_id_for_tab(@product, 'MeasureTest', false)}\"]").click
end

When(/^the user switches to the filtering test tab$/) do
  page.find(:xpath, "//a[@href=\"##{html_id_for_tab(@product, 'FilteringTest')}\"]").click
end

# product test number the number of product test (1 indexed) for upload in order of most recently created
def td_div_id_for_cat1_task_for_product_test(product_test_number)
  "#wrapper-task-id-#{nth_measure_test(product_test_number).tasks.c1_task.id}"
end

def td_div_id_for_cat3_task_for_product_test(product_test_number)
  "#wrapper-task-id-#{nth_measure_test(product_test_number).tasks.c2_task.id}"
end

# one indexed. ex.) mesure_test_number == 1 is the first measure test created
def nth_measure_test(measure_test_number)
  @product.product_tests.measure_tests.sort { |x, y| x.created_at <=> y.created_at }[measure_test_number.to_i - 1]
end

def td_div_id_for_cat1_task_for_filtering_test(filtering_test_number)
  "#wrapper-task-id-#{nth_filtering_test(filtering_test_number).tasks.cat1_filter_task.id}"
end

def td_div_id_for_cat3_task_for_filtering_test(filtering_test_number)
  "#wrapper-task-id-#{nth_filtering_test(filtering_test_number).tasks.cat3_filter_task.id}"
end

def nth_filtering_test(filtering_test_number)
  @product.product_tests.filtering_tests.sort { |x, y| x.created_at <=> y.created_at }[filtering_test_number.to_i - 1]
end

def attach_zip_to_multi_upload(html_id)
  show_hidden_upload_field(html_id)

  # attach zip file to multi-upload field
  zip_path = File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip')
  page.find(html_id, visible: false).attach_file('test_execution[results]', zip_path, visible: false)
end

def attach_xml_to_multi_upload(html_id)
  show_hidden_upload_field(html_id)

  # attach zip file to multi-upload field
  xml_path = File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml')
  page.find(html_id, visible: false).attach_file('test_execution[results]', xml_path, visible: false)
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
  page.has_unchecked_field?('input.measure-group-all')
end

Then(/^all measures should still be selected$/) do
  assert page.all('#measure_tabs fieldset .checkbox input').all?(&:checked?)
end

Then(/^"([^"]*)" is active on the screen$/) do |measure|
  page.find('#measure_tabs').assert_text measure
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

# V V V product tests tabs V V V #

Then(/^the user should see the the appropriate tabs$/) do
  if @product.c1_test
    title, description, html_id = title_description_and_html_id_for(@product, 'ChecklistTest')
    assert_tab_and_content_exist(title, description, html_id)
  end
  if @product.c2_test
    title, description, html_id = title_description_and_html_id_for(@product, 'MeasureTest', true)
    assert_tab_and_content_exist(title, description, html_id) if @product.c1_test
    title, description, html_id = title_description_and_html_id_for(@product, 'MeasureTest', false)
    assert_tab_and_content_exist(title, description, html_id)
  end
  if @product.c4_test
    title, description, html_id = title_description_and_html_id_for(@product, 'FilteringTest')
    assert_tab_and_content_exist(title, description, html_id)
  end
end

def assert_tab_and_content_exist(title, description, html_id)
  page.click_link title
  find("##{html_id}", visible: false).assert_text description
end

Then(/^the user should not see the measure tests tab$/) do
  page.assert_no_text 'Measure Tests'
end

Then(/^the user should see the filtering tests tab$/) do
  page.assert_text 'CQM Filtering Test'
  find('#FilteringTest').assert_text 'Test the EHR system\'s ability to filter patient records'
end

Then(/^the user should not see the filtering tests tab$/) do
  page.assert_no_text 'CQM Filtering Test'
end

Then(/^the user should see the checklist tests tab$/) do
  page.assert_text 'Manual Entry Test'
  find('#ChecklistTest').assert_text 'Validate the EHR system for C1 certification by manually entering specified patient data for the following'
end

Then(/^the user should not see the checklist tests tab$/) do
  page.assert_no_text 'Manual Entry Test'
end

# ^ ^ ^ product tests tabs ^ ^ ^ #

Then(/^the user should be able to download all patients$/) do
  page.assert_text 'Download All Patients'
end

Then(/^the user should not be able to download all patients$/) do
  page.assert_no_text 'Download All Patients'
  page.assert_text 'records are being built'
end

Then(/^the user should be able to download the report$/) do
  page.assert_text 'Download Report'
end

Then(/^the user should not be able to download the report$/) do
  page.assert_no_text 'Download Report'
end

Then(/^the user should see a cat I test (.*) for product test (.*)$/) do |task_status, product_test_number|
  html_id_for_measure_test_table_row = "##{measure_tests_table_row_wrapper_id(nth_measure_test(product_test_number).tasks.c1_task)}"

  # html_id = td_div_id_for_cat1_task_for_product_test(product_test_number)
  measure_table_row_element = page.find(html_id_for_measure_test_table_row, visible: false)
  # byebug
  measure_table_row_element.assert_text task_status_to_execution_status_message(task_status)
end

Then(/^the user should see a cat III test (.*) for product test (.*)$/) do |task_status, product_test_number|
  html_id = td_div_id_for_cat3_task_for_product_test(product_test_number)
  html_elem = page.find(html_id, visible: false)
  html_elem.assert_text task_status_to_task_link_text(task_status)
end

Then(/^the user should see a cat I test (.*) for filtering test (.*)$/) do |task_status, filtering_test_number|
  html_id = td_div_id_for_cat1_task_for_filtering_test(filtering_test_number)
  html_elem = page.find(html_id, visible: false)
  html_elem.assert_text task_status_to_task_link_text(task_status)
end

Then(/^the user should see a cat III test (.*) for filtering test (.*)$/) do |task_status, filtering_test_number|
  html_id = td_div_id_for_cat3_task_for_filtering_test(filtering_test_number)
  html_elem = page.find(html_id, visible: false)
  html_elem.assert_text task_status_to_task_link_text(task_status)
end

def task_status_to_execution_status_message(task_status)
  case task_status
  when 'passing'
    'Passed'
  when 'failing'
    'Failed'
  when 'testing'
    'In Progress'
  when 'errored'
    'Errored'
  when 'incomplete'
    'Not Started'
  end
end

# task status should be one of 'testing', 'passing', 'failing'
def task_status_to_task_link_text(task_status)
  case task_status
  when 'passing'
    'view'
  when 'failing'
    'retry'
  when 'testing'
    'testing...'
  when 'incomplete'
    'start'
  end
end
