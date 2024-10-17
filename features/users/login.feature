Feature: Test Login Features

Background:
  Given a user has an account

Scenario: Unsuccessful login
  When the user tries to log in with invalid information
  Then the user should see an log in error message
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful login
  When the user logs in
  Then the user should see a sign out link
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Not Logged In
  When the user navigates to the home page
  Then the user should be redirected to the sign in page
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: Unsuccessful umls login
  When the user tries to log in with invalid umls information
  Then the user should see an umls error message
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  