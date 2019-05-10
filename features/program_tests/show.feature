Feature: Program Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successfully View a Program Test
  When the user creates a cvu plus product
  And the user views CPCPLUS program task
  Then the user should see instructions
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
