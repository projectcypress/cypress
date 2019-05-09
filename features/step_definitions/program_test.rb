include TestExecutionsHelper

# # # # # # # #
#   W H E N   #
# # # # # # # #

And(/^the user views cpcplus program task$/) do
  program_test = @product.product_tests.cms_program_tests.first
  visit product_program_test_path(@product, program_test)
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see instructions$/) do
  page.assert_text 'CMS Implmentation Guide Checklist Instructions'
end
