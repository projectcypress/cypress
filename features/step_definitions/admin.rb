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

When(/^the user navigates to the bundle_downloads page$/) do
  visit '/bundle_downloads'
end

When(/^the user selects bundle to download$/) do
  page.find('#bundle_download_bundle_year_2021').click
end

And(/^the user clicks download bundle$/) do
  page.click_button 'Download Bundle'
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

And(/^the driver is setup for accessability testing$/) do
  setup_accessabilty
end

And(/^the driver is returned to the default$/) do
  default_drivers
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
