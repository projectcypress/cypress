Feature: Test user account actions

Background:
  Given the user is signed in

Scenario: User wants to edit account information
  When the user clicks an account link
  Then the user should see an edit account page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Edit User
  When the user changes the account password
  Then the user is redirected to dashboard
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Edit User
  When the user incorrectly changes the account password
  Then the user should see a doesnt match error message
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Logout
  When the user logs out
  Then the user should be signed out
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
