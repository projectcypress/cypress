Feature: C1 Visual Checklist Test

Background:
  Given the user is signed in
  And the user has created a vendor with a product selecting C1 testing with one measure

Scenario: Edit Record Sample Test
  When the user creates a product that certifies c1, c3 and visits the record sample page
  Then the user should see a button to edit the checklist test
  And the user clicks the Edit Test button
  And the user picks Patient Characteristic Ethnicity: Ethnicity as a replacement for the first data criteria
  And the user saves the record sample test
  Then the QDM::PatientCharacteristicEthnicity data criteria should exist
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Edit Record Sample Test Attribute
  When the user creates a product that certifies c1, c3 and visits the record sample page
  Then the user should see a button to edit the checklist test
  And the user clicks the Edit Test button
  And the user picks relevantPeriod as a replacement for the first attribute
  And the user saves the record sample test
  Then the relevantPeriod attribute should exist
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  
