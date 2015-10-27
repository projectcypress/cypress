Feature: Vendor

Scenario: Successful Create Vendor
  Given a signed in user
  When the user creates a vendor with appropriate information
  Then the user should see a notification saying the vendor was created

Scenario: Unsuccessful Create Vendor Because No Name
  Given a signed in user
  When the user creates a vendor with no name
  Then the user should see an error message saying the vendor has no name

Scenario: Unsuccessful Create Vendor Because Name Taken
  Given a signed in user
  When the user creates two vendors with the same name
  Then the user should see an error message saying the vendor name has been taken

Scenario: Successful Cancel Create Vendor
  Given a signed in user
  When the user cancels creating a vendor
  Then the user should not see the vendor

Scenario: Successful Edit Vendor
  Given a signed in user
  And the user has created a vendor
  When the user edits the vendor
  Then the user should see a notification saying the vendor has been edited

Scenario: Successful Remove Vendor
  Given a signed in user
  And the user has created a vendor
  When the user removes the vendor
  Then the user should see a notification saying the vendor has been removed

Scenario: Successful Cancel Remove Vendor
  Given a signed in user
  And the user has created a vendor
  When the user cancels removing a vendor
  Then the user should still see the vendor

Scenario: Can View Vendor Information
  Given a signed in user
  And the user has created a vendor
  When the user views the vendor information
  Then the user should see the vendor name