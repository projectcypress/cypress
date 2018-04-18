Feature: Product Creation

Background:
  Given the user is signed in
  And the user has created a vendor

Scenario: View Create Product Page
  When the user navigates to the create product page
  Then the default bundle should be pre-selected
  Then the shift_records option should not be pre-selected
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

Scenario: Successful create Product with Supplemental Test Artifact
  When the user creates a product with a correct supplemental test artifact
  Then the user should see a notification saying the product was created
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful create Product with Supplemental Test Artifact
  When the user creates a product with a incorrect supplemental test artifact
  Then the user should see an error message saying "You are not allowed to upload"
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Create Product Because Name Taken
  When the user creates two products with the same name
  Then the user should see an error message saying "name was already taken"
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Create Product Because No Task Type Selected
  When the user creates a product with no task type
  Then the user should not be able to create a product
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Create Product with debug mode off and C2 Type selected
  When debug mode is false
  When a user creates a 2015 product with c1, c2 certifications and visits that product page
  Then the product value for randomize_patients should be true
  Then the product value for duplicate_patients should be true
  Then the product value for cert_edition should be 2015

Scenario: Successful Create Product with debug mode off and C1 Type selected
  When debug mode is false
  When a user creates a 2015 product with c1 certifications and visits that product page
  Then the product value for randomize_patients should be true
  Then the product value for duplicate_patients should be false
  Then the product value for cert_edition should be 2015

Scenario: Successful Create Product with debug mode off in 2014 cert mode and C2 Type selected
  When debug mode is false
  When a user creates a 2014 product with c1, c2 certifications and visits that product page
  Then the product value for randomize_patients should be true
  Then the product value for duplicate_patients should be false
  Then the product value for cert_edition should be 2014

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
  And the user types "CMS1234" into the measure filter box
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
  And the user types "CMS1234" into the measure filter box
  Then "CMS1234" is active on the screen

Scenario: Filtering properly hides irrelevant measures and tabs
  When the user navigates to the create product page
  And the user chooses the custom measure option
  And the user types "CMS1234" into the measure filter box
  Then "CMS1234" is active on the screen

Scenario: Changing certification type updates options appropriately
  When the user navigates to the create product page
  And the user chooses the "2014" Certification Edition
  Then "C4 Test" checkbox should be disabled
  Then "Duplicate Records" checkbox should be disabled

Scenario: Changing certification type back and forth updates options appropriately
  When the user navigates to the create product page
  And the user chooses the "2014" Certification Edition
  And the user chooses the "2015" Certification Edition
  Then "C4 Test" checkbox should be enabled
  Then "C4 Test" checkbox should be unchecked

Scenario: Checking C2 Test updates Duplidate Records appropriately on 2015 cert edition
  When the user navigates to the create product page
  And the user chooses the "2015" Certification Edition
  And the user chooses the "c2" Certification Type
  Then "Duplicate Records" checkbox should be enabled
  Then "Duplicate Records" checkbox should be checked
  Then "C4 Test" checkbox should be enabled
  Then "C4 Test" checkbox should be unchecked

Scenario: Checking C2 Test updates Duplidate Records appropriately on 2015 cert edition
  When the user navigates to the create product page
  And the user chooses the "2014" Certification Edition
  And the user chooses the "c2" Certification Type
  Then "Duplicate Records" checkbox should be disabled
  Then "Duplicate Records" checkbox should be unchecked
  Then "C4 Test" checkbox should be disabled

Scenario: Successful Cancel Create Product
  When the user cancels creating a product
  Then the user should not see the product
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
