Feature: Show Admin

Background:
  Given the user is signed in

Scenario: User is admin
  When the user is an admin
  And the user navigates to the admin page
  Then the page should be accessible

Scenario: User is not an admin
  When the user is not an admin
  And the user navigates to the admin page
  Then the page should not be accessible