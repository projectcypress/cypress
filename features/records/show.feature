Feature: Show Individual Record

Background:
  Given the user is signed in

Scenario: Successful view record
  When the user visits a record
  Then the user sees details
