Feature: Edit Vendor

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successful Edit Vendor
  When the user edits the vendor
  Then the user should see a notification saying the vendor has been edited
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Remove Vendor
  When the user removes the vendor
  Then the user should see a notification saying the vendor has been removed
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Cancel Remove Vendor
  When the user cancels removing a vendor
  Then the user should still see the vendor
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Can View Vendor Information
  When the user views the vendor information
  Then the user should see the vendor name
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
