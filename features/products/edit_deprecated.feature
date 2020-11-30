Feature: Edit Deprecated Product

Background:
  Given the user is signed in
  And the user has created a vendor with a product
  And the default bundle has been deprecated

Scenario: Successful View Deprecated Product Edit Page
  When the user views the edit page of the product
  Then the user should see a notification saying the product was deprecated
  Then the user should not see the Measures Options heading

Scenario: Successful Edit Deprecated Product
  When the user changes the name of the product
  Then the user should see a notification saying the product was edited

Scenario: Successful Remove Deprecated Product
  When the user removes the product
  Then the user should see a notification saying the product was removed

Scenario: Successful Remove Deprecated Product From Vendor Page
  When the user removes the product from the vendor page
  Then the user should see a notification saying the product was removed

Scenario: Successful Cancel Remove Deprecated Product
  When the user cancels removing the product
  Then the user should still see the product

Scenario: Can View Deprecated Product Information
  When the user views the product
  Then the user should see the product information
