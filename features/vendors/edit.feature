Feature: Edit Vendor

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successful Edit Vendor
  When the user edits the vendor

Scenario: Successful Remove Vendor
  When the user removes the vendor

Scenario: Successful Cancel Remove Vendor
  When the user cancels removing a vendor
  Then the user should still see the vendor

Scenario: Can View Vendor Information
  When the user views the vendor information
  Then the user should see the vendor name

Scenario: Can View Vendor Preference
  When the user views the vendor preferences
  Then the user should see choose code system preferences
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: Can Save Vendor Preference
  When the user views the vendor preferences
  Then the user should see choose code system preferences
  Then the user should see save code system preferences
