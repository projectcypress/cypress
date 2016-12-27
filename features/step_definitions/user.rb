Given(/^the user is signed in$/) do
  steps %( Given a user has an account )
  login_as @user, :scope => :user
  steps %( Given the user is on the sign in page )
end

Given(/^the user is on the sign in page$/) do
  visit '/'
end

And(/^there are no bundles installed$/) do
  Bundle.destroy_all
  Rails.cache.clear
  assert Bundle.count == 0
end

When(/^I click Sign up$/) do
  page.click_link_or_button 'Sign up'
  sleep(1) # Gross, but otherwise this randomly fails @SS
end

When(/^I fill in the form with correct information$/) do
  steps %( When I fill in the form without accepting the T&C )
  page.check 'I agree to the above Terms and Conditions'
end

Then(/^I should have a new account$/) do
  assert_not_nil User.find_by(email: @email)
  assert_equal vendors_path, page.current_path
end

Then(/^I should not be able to submit the form$/) do
  path = page.current_path
  page.find("input[type='submit']").click
  assert_equal path, page.current_path
  assert_nil User.where(email: @email).first
end

When(/^I fill in the form without accepting the T&C$/) do
  @email = 's@s.com'
  @password = 'Password1'
  page.fill_in 'Email', with: @email
  page.fill_in 'Password', with: @password
  page.fill_in 'Confirm Password', with: @password
  page.fill_in 'Email', with: @email
  page.fill_in 'Password', with: @password
  page.fill_in 'Confirm Password', with: @password
end

Given(/^the user is on the sign up page$/) do
  visit new_user_registration_path
end

Then(/^I should be on the account creation page$/) do
  assert_equal new_user_registration_path, page.current_path
end

Given(/^a user has an account$/) do
  User.all.destroy # FIXME: there's gotta be a better way
  @user = FactoryGirl.create(:user)
  @user.add_role :admin
end

When(/^the user tries to log in with invalid information$/) do
  visit '/users/sign_in'
  page.fill_in 'Email', with:  'unauth@mitre.org'
  page.fill_in 'Password', with:  'incorrectPassword'
  page.click_button 'Sign in'
end

When(/^the user navigates to the home page$/) do
  visit '/'
end

When(/^the user clicks an account link$/) do
  visit '/'
  page.click_link(@user.email)
end

When(/^the user should see an edit account page$/) do
  page.assert_text 'Edit User'
end

When(/^the user logs in$/) do
  visit '/users/sign_in'
  page.fill_in 'Email', with:  @user.email
  page.fill_in 'Password', with:  @user.password
  page.click_button 'Sign in'
end

When(/^the user logs out$/) do
  page.click_link 'Log Out'
end

Then(/^the user should see an log in error message$/) do
  page.assert_text 'Invalid Email or password.'
end

Then(/^the user should see an log in success message$/) do
  page.assert_text 'Signed in successfully'
end

Then(/^the user should see a sign out link$/) do
  page.assert_text 'Log Out'
end

Then(/^the user should not see a warning message$/) do
  page.assert_no_text 'You need to sign in or sign up before continuing.'
end

Then(/^the user should be redirected to the sign in page$/) do
  assert_equal new_user_session_path, page.current_path
end

Then(/^the user should be signed out$/) do
  # assert redirected_to destroy_user_session_path
  page.assert_text 'Signed out successfully.'
  assert_equal user_session_path, page.current_path
end
