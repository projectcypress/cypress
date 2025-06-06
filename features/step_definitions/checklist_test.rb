# frozen_string_literal: true

include ProductsHelper

# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has created a vendor with a product selecting C1 testing with one measure$/) do
  measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
  @vendor = FactoryBot.create(:vendor)
  @bundle_id = Bundle.default._id
  @product = Product.new(vendor: @vendor, name: 'Product 1', c1_test: true, measure_ids:, bundle_id: @bundle_id)
  @product.product_tests.build({ name: 'test_for_measure_1a', measure_ids: }, MeasureTest)
  checklist_test = @product.product_tests.build({ name: 'record sample test', measure_ids: }, ChecklistTest)
  @product.save!
  checklist_test.tasks.create!({}, C1ChecklistTask)
end

And(/^the user views that product$/) do
  visit vendor_product_path(@vendor, @product)
end

And(/^the user views the record sample tab$/) do
  html_id = html_id_for_tab(@product, 'ChecklistTest')
  page.find("[href='##{html_id}']").click
end

And(/^the user picks (.*) as a replacement for the first data criteria$/) do |criteria_text|
  page.select(criteria_text, from: 'product_test_checked_criteria_attributes_0_replacement_data_criteria')
end

And(/^the user picks (.*) as a replacement for the first attribute$/) do |attribute_text|
  # may use simplify_criteria(test, include_attribute_code = false) if needed for consistent results
  page.select(attribute_text, from: 'product_test_checked_criteria_attributes_0_replacement_attribute')
end

And(/^the user saves the record sample test$/) do
  page.find("input[value='Save']").click
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

# certification types should be a comma separated list either: 'c1' or 'c1, c3'
When(/^the user creates a product that certifies (.*) and visits the record sample page$/) do |certification_types|
  measure_ids = ['AE65090C-EB1F-11E7-8C3F-9A214CF093AE']
  certification_types = certification_types.split(', ')
  @product = @vendor.products.build(name: "my product #{rand}", measure_ids:, bundle_id: @bundle_id)
  @product.c1_test = true if certification_types.include? 'c1'
  @product.c3_test = true if certification_types.include? 'c3'
  @product.save!
  test = @product.product_tests.create!({ name: "my checklist test #{rand}", measure_ids: }, ChecklistTest)
  test.create_checked_criteria
  test.tasks.create!({}, C1ChecklistTask) if @product.c1_test
  test.tasks.create!({}, C3ChecklistTask) if @product.c3_test
  visit product_checklist_test_path(@product, test)
end

#   A N D   #

When(/^the user views that record sample test$/) do
  page.find("input[type = submit][value = 'View Record Sample']").click
end

And(/^the user deletes the checklist test$/) do
  page.click_button 'Delete Visual Test'
  page.fill_in 'Remove Name', with: 'delete checklist'
  page.click_button 'Remove'
end

When(/^the user fills out the record sample with bad data$/) do
  @product.product_tests.checklist_tests.first.checked_criteria.each_with_index do |_, i|
    page.fill_in "product_test[checked_criteria_attributes][#{i}][code]", with: "not correct code #{i} #{rand}"
  end
  page.click_button 'Save'
end

# reduce number of checklist criteria and fill out those two criterias with valid information
When(/^the user fills out the record sample with good data$/) do
  @test = @product.product_tests.checklist_tests.first
  @test.state = :ready
  simplify_source_data_criteria(@test)
  @test.save!
  visit product_checklist_test_path(@product, @test)
  page.fill_in 'product_test[checked_criteria_attributes][0][code]', with: '720'
  page.fill_in 'product_test[checked_criteria_attributes][0][attribute_code]', with: '210'
  page.click_button 'Save'
end

def simplify_source_data_criteria(test)
  criteria = test.checked_criteria[0, 1]
  criteria[0].source_data_criteria = { 'codeListId' => '1.8.9.10',
                                       '_id' => BSON::ObjectId.new,
                                       'hqmfOid' => '2.16.840.1.113883.10.20.28.4.5',
                                       '_type' => 'QDM::EncounterPerformed',
                                       'description' => 'encounter',
                                       'qdmCategory' => 'encounter',
                                       'dataElementAttributes' => [{ 'attribute_name' => 'relevantPeriod',
                                                                     'attribute_valueset' => nil },
                                                                   { 'attribute_name' => 'dischargeDisposition',
                                                                     'attribute_valueset' => '1.5.6.7' }] }
  criteria[0].attribute_index = 1
  test.checked_criteria = criteria
  test.save!
end

# should create a test that includes codes for all checked criteria and produces no test execution errors
When(/^the user uploads a Cat I file and waits for results$/) do
  upload_and_submit(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_correct_codes.zip'))
  wait_for_all_delayed_jobs_to_run
end

# should create a test that does not include codes for all checked criteria and produces test execution errors
When(/^the user uploads a bad Cat I file and waits for results$/) do
  upload_and_submit(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_incorrect_codes.zip'))
  wait_for_all_delayed_jobs_to_run
end

# should create a test that includes codes for all checked criteria but produces test execution errors
# input should be either 'c1' or 'c3'
When(/^the user uploads a Cat I file that produces a qrda error on (.*) task's execution and waits for results$/) do |certification_type|
  upload_and_submit(Rails.root.join('test', 'fixtures', 'qrda', 'cat_I', 'c1_checklist_correct_codes_bad_form.zip'))
  wait_for_all_delayed_jobs_to_run
  execution = @test.tasks.c1_checklist_task.most_recent_execution if certification_type == 'c1'
  execution = @test.tasks.c3_checklist_task.most_recent_execution if certification_type == 'c3'
  execution.execution_errors.create!(message: "my execution error #{rand}", msg_type: 'error')
end

def upload_and_submit(file_path)
  find('span', class: 'btn-file').click
  page.attach_file('results', file_path, visible: false)
  page.find('#submit-upload').click
end

When(/^the user visits the individual measure checklist page for measure (.*)$/) do |measure_number|
  measure = nth_measure(measure_number)
  visit measure_checklist_test_path(@test, measure)
end

def nth_measure(measure_number)
  @test.measures.sort_by(&:created_at)[measure_number.to_i - 1]
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the checklist test$/) do
  assert_text(APP_CONSTANTS['tests']['ChecklistTest']['description'])
end

Then(/^the user should see a button to revisit the checklist test$/) do
  assert page.find('#c1_sample').has_link? 'CMS32v7 Static Measure'
  # assert page.has_selector?("input[type = submit][value = 'View Test']")
end

Then(/^the user should (not )?see a button to edit the checklist test$/) do |not_present|
  selector_presence = page.has_selector?('#modifyrecord')
  puts not_present
  if not_present
    assert !selector_presence
  else
    assert selector_presence
  end
end

Then(/^the user should be able to generate another checklist test$/) do
  steps %( And the user views the record sample tab )
  assert_equal false, page.has_selector?("input[type = submit][value = 'View Test']")
  assert page.has_selector?("input[type = submit][value = 'Start Test']")
end

Then(/^the user should see they are (.*) the checklist test$/) do |status|
  assert page.find('#display_checklist_status').assert_text status.capitalize
end

Then(/^the user should not be able to upload a Cat I file$/) do
  assert page.find('span.input-group-addon.info-disabled')
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
  (%w[C1 C3] - certification_types).each do |cert_type|
    assert page.find('#display_checklist_execution_results').assert_no_text "#{cert_type} Upload Results"
  end
end

Then(/^the user should see (.*) for upload results$/) do |status|
  assert page.find('#display_checklist_execution_results').assert_text task_status_to_execution_status_message(status)
end

def task_status_to_execution_status_message(task_status)
  status_description = { 'passing' => 'Passed',
                         'failing' => 'Failed',
                         'testing' => 'In Progress',
                         'errored' => 'Errored',
                         'incomplete' => 'Not Started' }
  status_description[task_status]
end

Then(/^the user should see the individual measure checklist page for measure (.*)$/) do |measure_number|
  measure = nth_measure(measure_number)
  page.assert_text(measure.cms_id)
  page.assert_text(measure.description)
  page.assert_text 'Return to Record Sample'
end

Then(/^the (.*) data criteria should exist$/) do |criteria_text|
  assert page.has_text?(criteria_text)
end

Then(/^the (.*) attribute should exist$/) do |attribute_text|
  assert page.has_text?(attribute_text)
end
