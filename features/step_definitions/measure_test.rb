include TestExecutionsHelper

# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user has selected a measure$/) do
  @measure = Measure.first
end

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user creates a product with tasks (.*)$/) do |tasks|
  measure_ids = ['40280381-4BE2-53B3-014C-0F589C1A1C39']
  tasks = tasks.split(', ')
  @product = Product.new(vendor: @vendor, name: 'Product 1', measure_ids: measure_ids, c1_test: tasks.include?('c1'),
                         c2_test: tasks.include?('c2'), c3_test: tasks.include?('c3'), c4_test: tasks.include?('c4'), bundle_id: @measure.bundle_id)
  @product.save!
  @product_test = @product.product_tests.create!({ name: @measure.name, measure_ids: measure_ids }, MeasureTest)

  # create record and assign provider for product test
  provider = Provider.find('53b2c4414d4d32139c730000')
  @product_test.provider = provider
  @product_test.save!
  provider_performance = ProviderPerformance.new(provider: provider, provider_id: provider.id)
  Record.create!(test_id: @product_test.id, provider_performances: [provider_performance])
end

#   A N D   #

# only include one task_name for task_names
And(/^the user views task (.*)$/) do |task_names|
  task = task_names.include?('c1') ? @product_test.tasks.c1_task : @product_test.tasks.c2_task
  visit new_task_test_execution_path(task)
end

And(/^the user switches to c2 certification$/) do
  find(:xpath, "//a[@href='/tasks/#{@product_test.tasks.c2_task.id}/test_executions/new']").trigger('click')
end

And(/^the user switches to c2 and c3 certification$/) do
  find(:xpath, "//a[@href='/tasks/#{@product_test.tasks.c2_task.id}/test_executions/new']").trigger('click')
end

And(/^the product test state is set to ready$/) do
  ProductTest.all.each do |pt|
    pt.state = :ready
    pt.save!
  end
end

And(/^the product test state is not set to ready$/) do
  @product_test.state = :garbablargblarg
  @product_test.save!
end

And(/^the user uploads a CAT 1 zip file$/) do
  zip_path = File.join(Rails.root, 'test/fixtures/product_tests/ep_qrda_test_good.zip')
  page.attach_file('results', zip_path, visible: false)
  page.find('#submit-upload').click
end

And(/^the user uploads a CAT 3 XML file$/) do
  xml_path = File.join(Rails.root, 'test/fixtures/product_tests/cms111v3_catiii.xml')
  page.attach_file('results', xml_path, visible: false)
  page.find('#submit-upload').click
end

And(/^the user uploads an invalid file$/) do
  invalid_file_path = File.join(Rails.root, 'app/assets/images/icon.svg')
  page.attach_file('results', invalid_file_path, visible: false)
  page.find('#submit-upload').click
end

# task_names should be either 'c1', 'c2', or both
When(/^the user waits for results then views task (.*)$/) do |task_names|
  wait_for_all_delayed_jobs_to_run
  task = task_names.include?('c1') ? @product_test.tasks.c1_task : @product_test.tasks.c2_task
  visit new_task_test_execution_path(task)
end

When(/^the user views the uploaded xml$/) do
  # page.click_button 'View Uploaded XML with Errors'
  visit file_result_test_execution_path(@product_test.tasks.c2_task.most_recent_execution, route_file_name('cms111v3_catiii.xml'))
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the upload functionality for that product test$/) do
  page.assert_text @measure.name
  page.assert_text 'Download Test Deck'
end

Then(/^the user should see provider information$/) do
  page.assert_text 'Provider Name'
  page.assert_text 'Provider NPI'
  page.assert_text 'Provider TIN'
end

Then(/^the user should only see the c1 execution page$/) do
  page.find('#task_status_display').assert_text 'C1'
  page.find('#task_status_display').assert_no_text 'C2'
end

Then(/^the user should only see the c2 execution page$/) do
  page.find('#task_status_display').assert_text 'C2'
  page.find('#task_status_display').assert_no_text 'C1'
end

Then(/^the user should see the c2 execution page$/) do
  find('#task_status_display').assert_text 'C1'
  find(:xpath, "//a[@href='/tasks/#{@product_test.tasks.c1_task.id}/test_executions/new']").assert_text 'C1'
end

Then(/^the user should see the c2 and c3 execution page$/) do
  find('#task_status_display').assert_text 'C2'
  find('#task_status_display').assert_text 'C3'
  find(:xpath, "//a[@href='/tasks/#{@product_test.tasks.c1_task.id}/test_executions/new']").assert_text 'C1'
  find(:xpath, "//a[@href='/tasks/#{@product_test.tasks.c1_task.id}/test_executions/new']").assert_text 'C3'
end

Then(/^the user should be able to download a CAT 1 zip file$/) do
  page.assert_text 'Download QRDA Category I (.zip)'
end

Then(/^the user should not be able to download a CAT 1 zip file$/) do
  page.assert_text 'is building test'
  page.assert_no_text 'Download QRDA Category I (.zip)'
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

Then(/^the user should see a link to view the the uploaded xml$/) do
  page.find(:xpath, "//input[@value='View Uploaded XML with Errors']")
end

Then(/^the user should see the uploaded xml$/) do
  page.assert_text '<?xml versio'
end
