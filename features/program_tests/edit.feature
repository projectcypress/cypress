Feature: Program Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successfully Enter Data for a Program Test
  When the user creates a cvu plus product
  And the user views cpcplus program task
  And the user fills out the program test with good data
  Then the program test should have a program_criteria with the entered value
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successfully Upload QRDA III for a Program Test and Views Results
  When the user creates a cvu plus product
  And the user views cpcplus program task
  And the user fills out the program test with good data
  And the user uploads a Cat III file and waits for results
  And the user should be able to click view results
  Then the user should see errors and warnings
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successfully Upload QRDA III for a Program Test and Views Product
  When the user creates a cvu plus product
  And the user views cpcplus program task
  And the user fills out the program test with good data
  And the user uploads a Cat III file and waits for results
  And the user visits the product page
  Then the user should see cms program tests
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa