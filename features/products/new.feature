Feature: Product Creation

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: Successfully Create Product
  When the user creates a product using appropriate information
  Then the user should see a notification saying the product was created

Scenario: Unsuccessful Create Product Because No Name
  When the user creates a product with no name
  Then the user should see an error message saying the product has no name

Scenario: Unsuccessful Create Product Because Name Taken
  When the user creates two products with the same name
  Then the user should see an error message saying the product name has been taken

Scenario: Successful Cancel Create Product
  When the user cancels creating a product
  Then the user should not see the product
