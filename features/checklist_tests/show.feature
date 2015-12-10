Feature: C1 Visual Checklist Test

Background:
  Given the user is signed in
  And the user has created a vendor with a product selecting C1 testing and 5 measures
  And the user views that product

Scenario: Successful Generate Checklist Test
  When the user generates a checklist test
  Then the user should be able to perform the checklist test

Scenario: Successful View Checklist Test
  When the user generates a checklist test
  And the user goes to perform the checklist test
  Then the user should see the checklist test

Scenario: Successful Delete Checklist Test
  When the user generates a checklist test
  And the user goes to perform the checklist test
  And the user deletes the checklist test
  Then the user be able to generate another checklist test