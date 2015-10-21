Given(/^a user has an account$/) do
  @user = FactoryGirl.create :user
end

When(/^the user tries to log in with invalid information$/) do
  visit '/users/sign_in'
  page.fill_in "Email", :with => "unauth@mitre.org"
  page.fill_in "Password", :with => "incorrectPassword"
  page.click_button "Log in"
end

Then(/^the user should see an log in error message$/) do
  page.assert_text "Invalid email or password."
end

When(/^the user logs in$/) do
  visit '/users/sign_in'
  page.fill_in "Email", :with => @user.email
  page.fill_in "Password", :with => @user.password
  page.click_button "Log in"
end

Then(/^the user should see an log in success message$/) do
  page.assert_text "Signed in successfully"
end

Then(/^the user should see a sign out link$/) do
  page.assert_text "Log Out"
end

Given(/^a signed in user$/) do
  login_as @user, :scope => :user
end

Then(/^the user logs out$/) do
  logout
end

Then(/^the user should see an log out success message$/) do
  page.assert_text "Signed out successfully"
end


Then(/^the user should click an account link$/) do
  visit '/'
  page.click_link("Account")


end

Then(/^the user should see an edit account page$/) do
  page.assert_text "Edit User"
end
