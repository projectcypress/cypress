Feature: Create Vendor

Background:
  Given the user is signed in
  And the user is on the create vendor page

Scenario: Successful Create Vendor
  When the user creates a vendor with appropriate information
  Then the user should see the vendor name
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: Unsuccessful Create Vendor Because No Name
  When the user creates a vendor with no name
  Then the user should not be able to create a vendor

Scenario: Unsuccessful Create Vendor Because Name Taken
  When the user creates two vendors with the same name
  Then the user should see an error message saying the vendor name has been taken

Scenario: Successful Cancel Create Vendor
  When the user cancels creating a vendor
  Then the user should not see the vendor
