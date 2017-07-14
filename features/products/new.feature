Feature: Product Creation

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: View Create Product Page
  When the user navigates to the create product page
  Then the default bundle should be pre-selected
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successfully Create Product
  When the user creates a product using appropriate information
  Then the user should see a notification saying the product was created
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Create Product Because No Name
  When the user creates a product with no name
  Then the user should not be able to create a product
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Create Product Because Name Taken
  When the user creates two products with the same name
  Then the user should see an error message saying the product name has been taken
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Create Product Because No Task Type Selected
  When the user creates a product with no task type
  Then the user should not be able to create a product
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Create Product with Multiple Measures From Different Groups
  When the user creates a product with multiple measures from different groups
  Then the user should see a notification saying the product was created
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Create Product with Group of Measures
  When the user creates a product with selecting a group of measures
  Then the user should see a notification saying the product was created
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Measure Group Unchecked After Deselecting Measure In Group
  When the user fills out all product information but measures
  And the user selects a group of measures but deselects one
  Then the group of measures should no longer be selected
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Filtering does not clear selected measures
  When the user navigates to the create product page
  And the user chooses the custom measure option
  And the user manually selects all measures
  And the user types "A Fake Measure" into the measure filter box
  And the user types "" into the measure filter box
  Then all measures should still be selected

Scenario: Clear all button functions when bundle is changed
  When the user navigates to the create product page
  And the user changes the selected bundle
  And the user changes the selected bundle
  And the user chooses the custom measure option
  And the user manually selects all measures
  And the user clicks the Clear all button
  Then there should be 0 measures selected

Scenario: Filtering properly hides irrelevant measures and tabs when one bundle is installed
  When the user has one bundle and navigates to the create product page
  And the user chooses the custom measure option
  And the user types "A fake measure" into the measure filter box
  Then "A fake measure" is active on the screen

Scenario: Filtering properly hides irrelevant measures and tabs
  When the user navigates to the create product page
  And the user chooses the custom measure option
  And the user types "A fake measure" into the measure filter box
  Then "A fake measure" is active on the screen

Scenario: Successful Cancel Create Product
  When the user cancels creating a product
  Then the user should not see the product
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
