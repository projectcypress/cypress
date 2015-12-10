Feature: Show Product

Background:
  Given the user is signed in
  And the user has created a vendor with a product

Scenario: Successful Download Total Test Deck
  When the user downloads all patients
  Then the total test deck should be downloaded