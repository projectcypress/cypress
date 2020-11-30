Feature: Multi Measure Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successfully View a Multi Measure Test
  When the user creates a cvu plus product
  And the user views multi measure cat3 task
  Then the user should see the download test deck link

Scenario: Successfully View a Multi Measure Test with expected results
  When the user creates a cvu plus product with records
  And the user views multi measure cat3 task
  Then the user should see the list expected results

