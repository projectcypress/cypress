Feature: Show Individual Record

Background:
  Given the user is signed in

Scenario: Successful view record
  When the user visits a record
  Then the user sees details
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful filter record
  When the user visits a record
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