# frozen_string_literal: true

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user is an admin$/) do
end

When(/^the user is not an admin$/) do
  @user.remove_role :admin
end

When(/^the user navigates to the admin page$/) do
  visit '/admin'
end

And(/^the user clicks edit application settings$/) do
  page.click_button 'Edit Application Settings'
end

And(/^the user clicks bundles$/) do
  page.find("[href='#bundles']").click
end

And(/^the user clicks import bundle$/) do
  page.click_button '+ Import Bundle'
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should be able to access the page$/) do
  page.assert_text 'Application Settings'
end

Then(/^the user should not be able to access the page$/) do
  page.assert_text 'not authorized'
end

Then(/^the user should be able to import bundle$/) do
  page.assert_text 'Import Bundle'
end
