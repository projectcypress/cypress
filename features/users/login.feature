Feature: Test Login Features

Background:
  Given a user has an account

Scenario: Unsuccessful login
  When the user tries to log in with invalid information
  Then the user should see an log in error message
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful login
  When the user logs in
  Then the user should see a sign out link
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Not Logged In
  When the user navigates to the home page
  Then the user should be redirected to the sign in page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
