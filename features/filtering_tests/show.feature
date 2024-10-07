Feature: C4 Filtering Test

Background:
  Given the user is signed in
  And the user has created a vendor with a product selecting C4 testing
  And the user visits the product show page with the filter test tab selected

Scenario: Successful View CAT 1 Filtering Test
  When the user views the CAT 1 test for the first filter task
  Then the user should see the CAT 1 test
  Then the user should not see provider information
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful View CAT 3 Filtering Test After Viewing CAT 1
  When the user views the CAT 1 test for the first filter task
  And the user views the CAT 3 test from the CAT 1 page
  Then the user should see the CAT 3 test
  Then the user should not see provider information
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Download CAT 1 Zip File From Filter Task
  When the user views the CAT 1 test for the first filter task
  Then the user should be able to download a CAT 1 zip file
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Upload CAT 1 Zip File to Filter Task
  When the user views the CAT 1 test for the first filter task
  And the user uploads a CAT 1 zip file
  Then the user should see test results
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Upload CAT 3 XML File to Filter Task
  When the user views the CAT 3 test for the first filter task
  And the user uploads a CAT 3 XML file
  Then the user should see test results
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful hide View Expected Result for Filter Task for non admin
  When the user is not an admin
  And the user has viewed the CAT 1 test for the first filter task
  Then the user should not see the View Expected Result option
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful View Expected Result for Filtering Test for admin
  When the user is changed to an admin
  And the user has viewed the CAT 1 test for the first filter task
  And the user views the Expected Result Patient List page
  Then the user should see a list of expected patients
  Then the user should see a Total row
  # TODO: bring this back later
  # And the user selects download html patients
  # Then a zip file should be downloaded within 2 seconds
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

