Feature: C1 Visual Checklist Test

Background:
  Given the user is signed in
  And the user has created a vendor with a product selecting C1 testing with one measure
  And the user views that product

Scenario: Successful Revisit Checklist Test
  When the user views the manual entry tab
  And the user views that product
  And the user views the manual entry tab
  Then the user should see a button to revisit the checklist test
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Fill Out Checklist Incorrectly Produces Errors
  When the user creates a product that certifies c1 and visits the manual entry page
  And the user fills out the manual entry with bad data
  Then the user should see they are failing the manual entry test
  And the user should not be able to upload a Cat I file

Scenario: Fill Out Checklist Correctly
  When the user creates a product that certifies c1 and visits the manual entry page
  And the user fills out the manual entry with good data
  Then the user should see checkmarks next to each complete data criteria
  And the user should be able to upload a Cat I file

Scenario: Successful Upload Cat I file After Completing Checklist
  When the user creates a product that certifies c1 and visits the manual entry page
  And the user fills out the manual entry with good data
  And the user uploads a Cat I file and waits for results
  Then the user should see they are passing the manual entry test
  And the user should see upload results for c1 certifications
  And the user should see passing for upload results

Scenario: Successful Upload Bad Cat I file After Completing Checklist Produces Errors
  When the user creates a product that certifies c1 and visits the manual entry page
  And the user fills out the manual entry with good data
  And the user uploads a bad Cat I file and waits for results
  Then the user should see they are failing the manual entry test
  And the user should see upload results for c1 certifications
  And the user should see failing for upload results

Scenario: Upload Cat I with QRDA Errors but Valid Source Data Criteria
  When the user creates a product that certifies c1 and visits the manual entry page
  And the user fills out the manual entry with good data
  And the user uploads a Cat I file that produces a qrda error on c1 task's execution and waits for results
  Then the user should see they are passing the manual entry test
  And the user should see upload results for c1 certifications
  And the user should see failing for upload results

Scenario: Successful Upload Cat I file After Completing Checklist for Product with C1 and C3 Selected
  When the user creates a product that certifies c1, c3 and visits the manual entry page
  And the user fills out the manual entry with good data
  And the user uploads a Cat I file and waits for results
  Then the user should see they are passing the manual entry test
  And the user should see upload results for c1, c3 certifications
  And the user should see passing for upload results

Scenario: Successful Upload Bad Cat I file After Completing Checklist Produces Errors for Product with C1 and C3 Selected
  When the user creates a product that certifies c1, c3 and visits the manual entry page
  And the user fills out the manual entry with good data
  And the user uploads a bad Cat I file and waits for results
  Then the user should see they are failing the manual entry test
  And the user should see upload results for c1, c3 certifications
  And the user should see failing for upload results

Scenario: Upload Cat I with QRDA Error on C1 Manual Task Execution but Valid Source Data Criteria for Product with C1 and C3 Selected
  When the user creates a product that certifies c1, c3 and visits the manual entry page
  And the user fills out the manual entry with good data
  And the user uploads a Cat I file that produces a qrda error on c1 task's execution and waits for results
  Then the user should see they are passing the manual entry test
  And the user should see upload results for c1, c3 certifications
  And the user should see failing for upload results

Scenario: Upload Cat I with QRDA Error on C3 Manual Task Execution but Valid Source Data Criteria for Product with C1 and C3 Selected
  When the user creates a product that certifies c1, c3 and visits the manual entry page
  And the user fills out the manual entry with good data
  And the user uploads a Cat I file that produces a qrda error on c3 task's execution and waits for results
  Then the user should see they are passing the manual entry test
  And the user should see upload results for c1, c3 certifications
  And the user should see failing for upload results