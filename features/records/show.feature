Feature: Show Individual Record

Background:
  Given the user is signed in

Scenario: Successful view record
  When the user visits a record
  Then the user sees details
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

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