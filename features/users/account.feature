Feature: Test user account actions

Background:
  Given the user is signed in

Scenario: User wants to edit account information
  When the user clicks an account link
  Then the user should see an edit account page
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Logout
#  TODO: Why do you fail for undefined method `escape' for URI:Module
  When the user logs out
  Then the user should be signed out
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: User can edit account information
  When the user clicks an account link
  And the user changes their email
  And the user submits the edit user page
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  
