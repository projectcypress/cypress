include TestExecutionsHelper

# # # # # # # #
#   W H E N   #
# # # # # # # #

And(/^the user views (.*) program task$/) do |program_name|
  @program_test = @product.product_tests.cms_program_tests.where(cms_program: program_name).first
  visit product_program_test_path(@product, @program_test)
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see instructions$/) do
  page.assert_text 'CMS Implmentation Guide Checklist Instructions'
end

Then(/^the user should see errors and warnings$/) do
  page.assert_text 'Errors and Warnings'
end

Then(/^the user should see measure calculations$/) do
  page.assert_text 'Measure Calculations'
end

Then(/^the user should see cms program tests$/) do
  page.assert_text 'CMS Program Tests'
end

When(/^the user fills out the program test with good data$/) do
  page.fill_in 'product_test[program_criteria_attributes][0][entered_value]', with: '1234567'
  page.click_button 'Save'
end

When(/^the program test should have a program_criteria with the entered value$/) do
  @program_test.reload
  assert_equal 1, @program_test.program_criteria.where(entered_value: '1234567').size
end

When(/^the user uploads a Cat III file and waits for results$/) do
  upload_and_submit(Rails.root.join('test', 'fixtures', 'qrda', 'cat_III', 'ep_test_qrda_cat3_good.xml'))
  wait_for_all_delayed_jobs_to_run
end

And(/^the user should be able to click view results/) do
  page.find('#result-link').click
end

def upload_and_submit(file_path)
  page.attach_file('results', file_path, visible: false)
  page.find('#submit-upload').click
end
