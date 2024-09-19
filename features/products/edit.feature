Feature: Edit Product

Background:
  Given the user is signed in
  And the user has created a vendor with a product

Scenario: Successful View Product Edit Page
  When the user views the edit page of the product
  Then the user should see the Measures Options heading
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Edit Product
  When the user changes the name of the product
  Then the user should see a notification saying the product was edited
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful edit Product with Supplemental Test Artifact
  When the user uploads a correct supplemental test artifact to the product
  Then the user should see a notification saying the product was edited
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Unsuccessful edit Product with Supplemental Test Artifact
  When the user uploads a incorrect supplemental test artifact to the product
  Then the user should see an error message saying "You are not allowed to upload"
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Cannot Download Supplemental Test Artifact when not an ATL
  Given the user is signed in as a non admin
  And the user has created a vendor with a product
  Given the user is owner of the vendor
  When the user uploads a correct supplemental test artifact to the product
  And the user visits the product page
  Then the user should not be able to download the supplemental test artifact
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Can Download a Supplemental Test Artifact
  When the user uploads a correct supplemental test artifact to the product
  And the user visits the product page
  Then the user should be able to download the supplemental test artifact
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Can Remove a Supplemental Test Artifact
  When the user uploads a correct supplemental test artifact to the product
  And the user removes the supplemental test artifact from the product
  And the user visits the product page
  Then the user should not be able to download the supplemental test artifact
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Remove Product
  When the user removes the product
  Then the user should see a notification saying the product was removed
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Remove Product From Vendor Page
  When the user removes the product from the vendor page
  Then the user should see a notification saying the product was removed
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful Cancel Remove Product
  When the user cancels removing the product
  Then the user should still see the product
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Can View Product Information
  When the user views the product
  Then the user should see the product information
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  
