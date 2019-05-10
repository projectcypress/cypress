Feature: Program Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successfully View a Program Test
  When the user creates a cvu plus product
  And the user views cpcplus program task
  And the user fills out the program test with good data
  Then the program test should have a program_criteria with the entered value
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
