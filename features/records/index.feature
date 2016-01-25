Feature: Show All Records

Background:
  Given the user is signed in

Scenario: View Master Patient List Page
  When the user visits the records page
  Then the user should see a list of patients
  And the user should see a way to filter patients

Scenario: Successful filter records
  When the user visits the records page
  And the user selects a measure from the dropdown
  Then the user should see results for that measure
