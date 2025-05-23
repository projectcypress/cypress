Feature: Program Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successfully Enter Data for a Program Test
  When the user creates a cvu plus product
  And the user views CPCPLUS program task
  And the user fills out the program test with good data
  Then the program test should have a program_criteria with the entered value
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successfully Upload QRDA III for a Program Test and Views Results
  When the user creates a cvu plus product
  And the user views CPCPLUS program task
  And the user fills out the program test with good data
  And the user uploads a Cat III file and waits for results
#  TODO: Why do you fail for undefined method `escape' for URI:Module
  And the user should be able to click view results
  Then the user should see errors and warnings
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successfully Upload QRDA III for a Program Test and Views Product
  When the user creates a cvu plus product
  And the user views CPCPLUS program task
  And the user fills out the program test with good data
  And the user uploads a Cat III file and waits for results
  And the user visits the product page
  Then the user should see cms program tests
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successfully Upload QRDA I for a Program Test and Views Results
  When the user creates a cvu plus product
  And the user views HQR_PI program task
  And the user fills out the program test with good data
  And the user uploads a Cat I file and waits for results
#  TODO: Why do you fail for undefined method `escape' for URI:Module
  And the user should be able to click view results
  Then the user should see errors and warnings
  Then the user should see measure calculations
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  