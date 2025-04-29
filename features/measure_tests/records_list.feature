Feature: Measure Test Records list

Background:
  Given the user is signed in
  And the user has created a vendor
  And the user has selected a measure

Scenario: Admin should be able to view calculation results
  When the user creates a product with records with tasks c1, c2, c3, c4
  And the user is an admin
  And the user views task c1
  And the user views the task records
  Then the user should see calculation results
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  
