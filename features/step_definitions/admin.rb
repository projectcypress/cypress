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

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should be able to access the page$/) do
  page.assert_text 'Application Settings'
end

Then(/^the user should not be able to access the page$/) do
  page.assert_text 'not authorized'
end
