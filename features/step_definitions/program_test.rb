include TestExecutionsHelper

# # # # # # # #
#   W H E N   #
# # # # # # # #

And(/^the user views cpcplus program task$/) do
  @program_test = @product.product_tests.cms_program_tests.first
  visit product_program_test_path(@product, @program_test)
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see instructions$/) do
  page.assert_text 'CMS Implmentation Guide Checklist Instructions'
end

When(/^the user fills out the program test with good data$/) do
  page.fill_in 'product_test[program_criteria_attributes][0][entered_value]', with: '1234567'
  page.click_button 'Save'
end

When(/^the program test should have a program_criteria with the entered value$/) do
  @program_test.reload
  assert_equal 1, @program_test.program_criteria.where(entered_value: '1234567').size
end
