Feature: Multi Measure Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successfully View a Multi Measure Test
  When the user creates a cvu plus product
  And the user views multi measure cat3 task
  Then the user should see the download test deck link
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successfully View a Multi Measure Test with expected results
  When the user creates a cvu plus product with records
  And the user views multi measure cat3 task
  Then the user should see the list expected results
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

