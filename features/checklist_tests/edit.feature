Feature: C1 Visual Checklist Test

Background:
  Given the user is signed in
  And the user has created a vendor with a product selecting C1 testing with one measure

Scenario: Edit Record Sample Test
  When the user creates a product that certifies c1, c3 and visits the record sample page
  Then the user should see a button to edit the checklist test
  And the user clicks the Edit Test button
  And the user picks Patient Characteristic Sex: ONCAdministrativeSex as a replacement for the first data criteria
  And the user saves the record sample test
  Then the Patient Characteristic Sex data criteria should exist

