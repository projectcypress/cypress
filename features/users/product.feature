Feature: Product

Scenario: Successfully Create Product
  Given a signed in user
  And the user has created a vendor
  When the user creates a product using appropriate information
  Then the user should see a notification saying the product was created

Scenario: Successfully Create Product With Eligible Provider
  Given a signed in user
  And the user has created a vendor
  When the user creates a product using appropriate information with eligible provider
  Then the user should see a notification saying the product was created

Scenario: Unsuccessful Create Product Because No Name
  Given a signed in user
  And the user has created a vendor
  When the user creates a product with no name
  Then the user should see an error message saying the product has no name

Scenario: Unsuccessful Create Product Because Name Taken
  Given a signed in user
  And the user has created a vendor
  When the user creates two products with the same name
  Then the user should see an error message saying the product name has been taken

Scenario: Unsuccessful Create Product Because No EHR Type
  Given a signed in user
  And the user has created a vendor
  When the user creates a product with no ehr type
  Then the user should see an error message saying the product has no ehr type

Scenario: Successful Cancel Create Product
  Given a signed in user
  And the user has created a vendor
  When the user cancels creating a product
  Then the user should not see the product

Scenario: Successful Edit Product
  Given a signed in user
  And the user has created a vendor with a product
  When the user changes the name of the product
  Then the user should see an notification saying the product was edited

Scenario: Successful Remove Product
  Given a signed in user
  And the user has created a vendor with a product
  When the user removes the product
  Then the user should see a notification saying the product was removed

Scenario: Successful Remove Product From Vendor Page
  Given a signed in user
  And the user has created a vendor with a product
  When the user removes the product from the vendor page
  Then the user should see a notification saying the product was removed

Scenario: Successful Cancel Remove Product
  Given a signed in user
  And the user has created a vendor with a product
  When the user cancels removing the product
  Then the user should still see the product

Scenario: Can View Product Information
  Given a signed in user
  And the user has created a vendor with a product
  When the user views the product
  Then the user should see the product information