include TestExecutionsHelper

# # # # # # # # #
#   G I V E N   #
# # # # # # # # #

#   A N D   #

And(/^the user views the task records$/) do
  page.click_link 'View Patients'
end

#  T H E N #

Then(/^the user should see calculation results$/) do
  page.assert_text('Template Name')
  page.assert_text('IPOP')
  page.assert_selector('span.result-marker')
end
