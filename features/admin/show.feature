Feature: Show Admin

Background:
  Given the user is signed in

Scenario: User is admin
  When the user is an admin
  And the user navigates to the admin page
  Then the user should be able to access the page
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa

Scenario: User can edit settings
  When the user is an admin
  And the user navigates to the admin page
  And the user clicks edit application settings
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa

Scenario: User can upload bundle
  When the user is an admin
  And the user navigates to the admin page
  And the user clicks bundles
  And the user clicks import bundle
  Then the user should be able to import bundle
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa

Scenario: User is not an admin
  When the user is not an admin
  And the user navigates to the admin page
  Then the user should not be able to access the page
