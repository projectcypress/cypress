Feature: Show Product

Background:
  Given the user is signed in
  And the user has created a vendor with a product

Scenario: Successful Download All Patients
  When all product tests have a state of ready
  And the user visits the product page
  Then the user should be able to download all patients
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Cannot View Download All Patients
  When all product tests do not have a state of ready
  And the user visits the product page
  Then the user should not be able to download all patients
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Can Download Report
  When all product tests have a state of ready
  And the user visits the product page
  Then the user should be able to view the report

Scenario: Can Multi Upload Cat I
  When all product tests have a state of ready
  And the user adds cat I tasks to all product tests
  And the user visits the product page
  And the user uploads a cat I document to product test 1
  Then the user should see a cat I test testing for product test 1

Scenario: Can Multi Upload Cat III
  When all product tests have a state of ready
  And the user visits the product page
  And the user uploads a cat III document to product test 1
  Then the user should see a cat III test testing for product test 1

Scenario: Can Multi Upload Multiple Times
  When the user adds a product test
  And all product tests have a state of ready
  And the user adds cat I tasks to all product tests
  And the user visits the product page
  And the user uploads a cat I document to product test 1
  And the user uploads a cat III document to product test 2
  Then the user should see a cat I test testing for product test 1
  And the user should see a cat III test testing for product test 2

Scenario: Can Multi Upload To Filtering Test
  When the user adds a product test
  And filtering tests are added to product
  And all product tests have a state of ready
  And the user visits the product page
  And the user switches to the filtering test tab
  And the user uploads a cat I document to filtering test 1
  And the user uploads a cat III document to filtering test 1
  Then the user should see a cat I test testing for filtering test 1
  And the user should see a cat III test testing for filtering test 1
