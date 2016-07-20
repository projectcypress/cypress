include ProductsHelper

# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product selecting C1 testing with one measure$/) do
  measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733']
  @vendor = FactoryGirl.create(:vendor)
  @product = Product.new(vendor: @vendor, name: 'Product 1', c1_test: true, measure_ids: measure_ids, bundle_id: '4fdb62e01d41c820f6000001')
  @product.product_tests.build({ name: 'test_for_measure_1a', measure_ids: measure_ids }, MeasureTest)
  checklist_test = @product.product_tests.build({ name: 'manual entry test', measure_ids: measure_ids }, ChecklistTest)
  @product.save!
  checklist_test.tasks.create!({}, C1ManualTask)
end

And(/^the user views that product$/) do
  visit vendor_product_path(@vendor, @product)
end

And(/^the user views the manual entry tab$/) do
  html_id = html_id_for_tab(@product, 'ChecklistTest')
  page.find("[href='##{html_id}']").click
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

# certification types should be a comma separated list either: 'c1' or 'c1, c3'
When(/^the user creates a product that certifies (.*) and visits the manual entry page$/) do |certification_types|
  measure_ids = ['40280381-4B9A-3825-014B-C1A59E160733']
  certification_types = certification_types.split(', ')
  @product = @vendor.products.build(name: "my product #{rand}", measure_ids: measure_ids, bundle_id: '4fdb62e01d41c820f6000001')
  @product.c1_test = true if certification_types.include? 'c1'
  @product.c3_test = true if certification_types.include? 'c3'
  @product.save!
  test = @product.product_tests.create!({ name: "my checklist test #{rand}", measure_ids: measure_ids }, ChecklistTest)
  test.create_checked_criteria
  test.tasks.create!({}, C1ManualTask) if @product.c1_test
  test.tasks.create!({}, C3ManualTask) if @product.c3_test
  visit product_checklist_test_path(@product, test)
end

#   A N D   #

When(/^the user views that checklist test$/) do
  page.find("input[type = submit][value = 'View Test']").click
end

And(/^the user deletes the checklist test$/) do
  page.click_button 'Delete Visual Test'
  page.fill_in 'Remove Name', with: 'delete checklist'
  page.click_button 'Remove'
end

When(/^the user fills out the manual entry with bad data$/) do
  @product.product_tests.checklist_tests.first.checked_criteria.each_with_index do |_, i|
    page.fill_in "product_test[checked_criteria_attributes][#{i}][code]", with: "not correct code #{i} #{rand}"
  end
  page.click_button 'Save'
end

# reduce number of checklist criteria and fill out those two criterias with valid information
When(/^the user fills out the manual entry with good data$/) do
  @test = @product.product_tests.checklist_tests.first
  @test.state = :ready
  simplify_source_data_criteria(@test)
  @test.save!
  visit product_checklist_test_path(@product, @test)
  page.fill_in 'product_test[checked_criteria_attributes][0][code]', with: '14183003'
  page.fill_in 'product_test[checked_criteria_attributes][0][attribute_code]', with: '63161005'
  page.fill_in 'product_test[checked_criteria_attributes][1][code]', with: '2186-5'
  page.click_button 'Save'
end

def simplify_source_data_criteria(test)
  criterias = test.checked_criteria[0, 2] # only use first two criteria
  criterias[0].source_data_criteria = 'DiagnosisActiveMajorDepressionIncludingRemission_precondition_40'
  criterias[1].source_data_criteria = 'PatientCharacteristicEthnicityEthnicity'
  test.checked_criteria = criterias
  test.save!
end

# should create a test that includes codes for all checked criteria and produces no test execution errors
When(/^the user uploads a Cat I file and waits for results$/) do
  upload_and_submit(File.join(Rails.root, 'test/fixtures/product_tests/test_manual_entry_upload_mr_testy.zip'))
  wait_for_all_delayed_jobs_to_run
end

# should create a test that does not include codes for all checked criteria and produces test execution errors
When(/^the user uploads a bad Cat I file and waits for results$/) do
  upload_and_submit(File.join(Rails.root, 'test/fixtures/product_tests/c1_manual_incorrect_codes.zip'))
  wait_for_all_delayed_jobs_to_run
end

# should create a test that includes codes for all checked criteria but produces test execution errors
# input should be either 'c1' or 'c3'
When(/^the user uploads a Cat I file that produces a qrda error on (.*) task's execution and waits for results$/) do |certification_type|
  upload_and_submit(File.join(Rails.root, 'test/fixtures/product_tests/test_manual_entry_upload_mr_testy.zip'))
  execution = @test.tasks.c1_manual_task.most_recent_execution if certification_type == 'c1'
  execution = @test.tasks.c3_manual_task.most_recent_execution if certification_type == 'c3'
  execution.execution_errors.create!(message: "my execution error #{rand}", msg_type: 'error')
  wait_for_all_delayed_jobs_to_run
end

def upload_and_submit(file_path)
  page.attach_file('results', file_path, visible: false)
  page.find('#submit-upload').click
end

def wait_for_all_delayed_jobs_to_run
  Delayed::Job.each do |delayed_job|
    Delayed::Worker.new.run(delayed_job)
  end
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the checklist test$/) do
  assert_text(APP_CONFIG['tests']['ChecklistTest']['description'])
end

Then(/^the user should see a button to revisit the checklist test$/) do
  assert page.find('#c1_manual').has_link? 'CMS159v4 Depression Remission at Twelve Months'
  # assert page.has_selector?("input[type = submit][value = 'View Test']")
end

Then(/^the user should be able to generate another checklist test$/) do
  steps %( And the user views the manual entry tab )
  assert_equal false, page.has_selector?("input[type = submit][value = 'View Test']")
  assert page.has_selector?("input[type = submit][value = 'Start Test']")
end

Then(/^the user should see they are (.*) the manual entry test$/) do |status|
  assert page.find('#display_checklist_status').assert_text status.capitalize
end

Then(/^the user should not be able to upload a Cat I file$/) do
  assert page.find('span.input-group-addon.disabled')
end

Then(/^the user should see checkmarks next to each complete data criteria$/) do
  @test.checked_criteria.each_with_index do |_, i|
    elem = page.find("[name='product_test[checked_criteria_attributes][#{i}][code]']")
    assert elem.find(:xpath, '../../i').visible? # make sure green checkmarks are visible
  end
end

Then(/^the user should be able to upload a Cat I file$/) do
  assert page.find('span.input-group-addon.active')
end

Then(/^the user should see upload results for (.*) certifications$/) do |certification_types|
  certification_types = certification_types.split(', ').map(&:upcase)
  certification_types.each do |cert_type|
    assert page.find('#display_checklist_execution_results').assert_text "#{cert_type} Upload Results"
  end

  # make sure certification types that should not be there are not there
  (%w(C1 C3) - certification_types).each do |cert_type|
    assert page.find('#display_checklist_execution_results').assert_no_text "#{cert_type} Upload Results"
  end
end

Then(/^the user should see (.*) for upload results$/) do |status|
  assert page.find('#display_checklist_execution_results').assert_text status.capitalize
end
