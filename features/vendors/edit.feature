Feature: Edit Vendor

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successful Edit Vendor
  When the user edits the vendor
  Then the user should see a notification saying the vendor has been edited

Scenario: Successful Remove Vendor
  When the user removes the vendor
  Then the user should see a notification saying the vendor has been removed

Scenario: Successful Cancel Remove Vendor
  When the user cancels removing a vendor
  Then the user should still see the vendor

Scenario: Can View Vendor Information
  When the user views the vendor information
  Then the user should see the vendor name
