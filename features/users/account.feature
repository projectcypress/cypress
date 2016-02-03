Feature: Test user account actions

Background:
  Given the user is signed in

Scenario: User wants to edit account information
  When the user clicks an account link
  Then the user should see an edit account page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Logout
  When the user logs out
  Then the user should be signed out
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
