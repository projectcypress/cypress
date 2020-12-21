Feature: Show Admin

Background:
  Given the user is signed in

Scenario: User is admin
  When the user is an admin
  And the user navigates to the admin page
  Then the user should be able to access the page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: User is not an admin
  When the user is not an admin
  And the user navigates to the admin page
  Then the user should not be able to access the page
