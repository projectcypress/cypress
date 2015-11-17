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

Scenario: Unsuccessful Create Product Because No Task Type Selected
  When the user creates a product with no task type
  Then the user should see an error message saying the product must have at least one task type

Scenario: Unsuccessful Create Product Because No Measure
  When the user creates a product without selecting a measure
  Then the user should see an error message saying the product must have at least one measure

Scenario: Successful Create Product with Multiple Measures From Different Groups
  When the user creates a product with multiple measures from different groups
  Then the user should see a notification saying the product was created

Scenario: Successful Create Product with Group of Measures
  When the user creates a product with selecting a group of measures
  Then the user should see a notification saying the product was created

Scenario: Unsuccessful Create Product Because Measure Deselected
  When the user creates a product with selecting a measure then deselecting that measure
  Then the user should see an error message saying the product must have at least one measure

Scenario: Unsuccessful Create Product Because Group Measure Deselected
  When the user creates a product with selecting a group of measures then deselecting that group
  Then the user should see an error message saying the product must have at least one measure

Scenario: Unsuccessful Create Product Because Measure Deselected From Selected Measures
  When the user creates a product with selecting a measure then deselecting from selected measures
  Then the user should see an error message saying the product must have at least one measure

Scenario: Measure Group Unchecked After Deselecting Measure In Group
  When the user fills out all product information but measures
  And the user selects a group of measures but deselects one
  Then the group of measures should no longer be selected

Scenario: Measure Group Unchecked After Deselecting Measure In Selected Measures
  When the user fills out all product information but measures
  And the user selects a group of measures but deselects one from selected measures
  Then the group of measures should no longer be selected

Scenario: No Product Tests Created if Product is Not Validated
  When the user creates a product with no name and selects measures
  Then there should be no product tests in the database

Scenario: Successful Cancel Create Product
  When the user cancels creating a product
  Then the user should not see the product
