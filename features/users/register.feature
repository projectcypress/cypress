Feature: Register for an account

Scenario: Navigate to the Sign Up page
  Given the user is on the sign in page
  When I click Sign up
  Then I should be on the account creation page

Scenario: Create an account
  Given the user is on the sign up page
  When I fill in the form with correct information
  And I click Sign up
  Then I should have a new account
  And the page should be accessible according to: section508
  And the page should be accessible according to: wcag2aa

Scenario: Create an account with no terms and conditions
  Given the user is on the sign up page
  When I fill in the form without accepting the T&C
  Then I should not be able to submit the form
  And the page should be accessible according to: section508
  And the page should be accessible according to: wcag2aa
