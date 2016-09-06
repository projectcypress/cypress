Feature: C4 Filtering Test

Background:
  Given the user is signed in
  And the user has created a vendor with a product selecting C4 testing
  And the first filter task state has been set to ready
  And the user visits the product show page with the filter test tab selected

Scenario: Successful View CAT 1 Filtering Test
  When the user views the CAT 1 test for the first filter task
  Then the user should see the CAT 1 test
  Then the user should not see provider information

Scenario: Successful View CAT 3 Filtering Test After Viewing CAT 1
  When the user views the CAT 1 test for the first filter task
  And the user views the CAT 3 test from the CAT 1 page
  Then the user should see the CAT 3 test
  Then the user should not see provider information

Scenario: Successful Download CAT 1 Zip File From Filter Task
  When the user views the CAT 1 test for the first filter task
  Then the user should be able to download a CAT 1 zip file

Scenario: Successful Upload CAT 1 Zip File to Filter Task
  When the user views the CAT 1 test for the first filter task
  And the user uploads a CAT 1 zip file
  Then the user should see test results

Scenario: Successful Upload CAT 3 XML File to Filter Task
  When the user views the CAT 3 test for the first filter task
  And the user uploads a CAT 3 XML file
  Then the user should see test results