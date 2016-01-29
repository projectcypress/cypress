Feature: Show All Records

Background:
  Given the user is signed in

Scenario: View Master Patient List Page
  When the user visits the records page
  Then the user should see a list of patients
  And the user should see a way to filter patients
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful filter records
  When the user visits the records page
  And the user selects a measure from the dropdown
  Then the user should see results for that measure
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
