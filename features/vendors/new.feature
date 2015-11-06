Feature: Create Vendor

Background:
  Given the user is signed in
  And the user is on the create vendor page

Scenario: Successful Create Vendor
  When the user creates a vendor with appropriate information
  Then the user should see a notification saying the vendor was created
  And the user should see the vendor name

Scenario: Unsuccessful Create Vendor Because No Name
  When the user creates a vendor with no name
  Then the user should see an error message saying the vendor has no name

Scenario: Unsuccessful Create Vendor Because Name Taken
  When the user creates two vendors with the same name
  Then the user should see an error message saying the vendor name has been taken

Scenario: Successful Cancel Create Vendor
  When the user cancels creating a vendor
  Then the user should not see the vendor
