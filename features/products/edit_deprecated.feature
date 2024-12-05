Feature: Edit Deprecated Product

Background:
  Given the user is signed in
  And the user has created a vendor with a product
  And the default bundle has been deprecated

Scenario: Successful View Deprecated Product Edit Page
  When the user views the edit page of the product
  Then the user should see a notification saying the product was deprecated
  Then the user should not see the Measures Options heading
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Edit Deprecated Product
  When the user changes the name of the product
  Then the user should see a notification saying the product was edited
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Remove Deprecated Product
  When the user removes the product
  Then the user should see a notification saying the product was removed
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Remove Deprecated Product From Vendor Page
  When the user removes the product from the vendor page
  Then the user should see a notification saying the product was removed
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Cancel Remove Deprecated Product
  When the user cancels removing the product
  Then the user should still see the product
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Can View Deprecated Product Information
  When the user views the product
  Then the user should see the product information
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  
