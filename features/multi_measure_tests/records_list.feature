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
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Admin should be able to view list of measures
  When the user creates a cvu plus product with records
  And the user is an admin
  And the user views multi measure cat3 task
  And the user views the task records
  Then the user should see the list of measures
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Admin should be able to filter patient data
  When the user creates a cvu plus product with records
  And the user is an admin
  And the user views multi measure cat3 task
  And the user views the task records
  And the user views a task record
  When the user filters on CMS134v6
  Then the user should see text Value Set Name 5
  When the user filters on CMS32v7
  Then the user should see text Value Set Name 8
  Then the user should not see text Value Set Name 5
  When the user filters on All Measures
  Then the user should see text Value Set Name 8
  Then the user should see text Value Set Name 5
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  