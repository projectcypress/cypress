Feature: Edit Product

Background:
  Given the user is signed in
  And the user has created a vendor with a product

Scenario: Successful View Product Edit Page
  When the user views the edit page of the product
  Then the user should see the Measures Options heading

Scenario: Successful Edit Product
  When the user changes the name of the product
  Then the user should see a notification saying the product was edited
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful edit Product with Supplemental Test Artifact
  When the user uploads a correct supplemental test artifact to the product
  Then the user should see a notification saying the product was edited
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful edit Product with Supplemental Test Artifact
  When the user uploads a incorrect supplemental test artifact to the product
  Then the user should see an error message saying "You are not allowed to upload"
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Cannot Download Supplemental Test Artifact when not an ATL
  Given the user is signed in as a non admin
  And the user has created a vendor with a product
  Given the user is owner of the vendor
  When the user uploads a correct supplemental test artifact to the product
  And the user visits the product page
  Then the user should not be able to download the supplemental test artifact

Scenario: Can Download a Supplemental Test Artifact
  When the user uploads a correct supplemental test artifact to the product
  And the user visits the product page
  Then the user should be able to download the supplemental test artifact

Scenario: Can Remove a Supplemental Test Artifact
  When the user uploads a correct supplemental test artifact to the product
  And the user removes the supplemental test artifact from the product
  And the user visits the product page
  Then the user should not be able to download the supplemental test artifact

Scenario: Successful Remove Product
  When the user removes the product
  Then the user should see a notification saying the product was removed
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Remove Product From Vendor Page
  When the user removes the product from the vendor page
  Then the user should see a notification saying the product was removed
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Cancel Remove Product
  When the user cancels removing the product
  Then the user should still see the product
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Can View Product Information
  When the user views the product
  Then the user should see the product information
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
