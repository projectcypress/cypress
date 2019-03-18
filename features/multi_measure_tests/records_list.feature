Feature: Multi Measure Test Records list

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Admin should be able to view calculation results
  When the user creates a cvu plus product with records
  And the user is an admin
  And the user views multi measure cat3 task
  And the user views the task records
  Then the user should see calculation results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Admin should be able to view list of measures
  When the user creates a cvu plus product with records
  And the user is an admin
  And the user views multi measure cat3 task
  And the user views the task records
  Then the user should see the list of measures
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa