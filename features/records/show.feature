Feature: Show Individual Record

Background:
  Given the user is signed in

Scenario: Successful view record
  When the user visits a record
  Then the user sees details
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
