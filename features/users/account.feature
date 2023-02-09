Feature: Test user account actions

Background:
  Given the user is signed in

Scenario: User wants to edit account information
  When the user clicks an account link
  Then the user should see an edit account page

Scenario: Successful Logout
#  TODO: Why do you fail for undefined method `escape' for URI:Module
  When the user logs out
  Then the user should be signed out

Scenario: User can edit account information
  When the user clicks an account link
  And the user changes their email
  And the user submits the edit user page
