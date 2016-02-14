Given(/^the user is signed in$/) do
  steps %( Given a user has an account )
  login_as @user, :scope => :user
  visit '/'
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
  page.click_link('Account')
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
  page.assert_text 'Invalid email or password.'
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
