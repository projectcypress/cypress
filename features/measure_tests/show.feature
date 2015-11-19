Feature: Measure Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor
  And the user has selected a measure

Scenario: Successfully View a Measure Test
  When the user creates a product with tasks c1
  And the user views a product test for that product
  Then the user should see the upload functionality for that product test

Scenario: View only CAT 1 Upload for C1
  When the user creates a product with tasks c1
  And the user views a product test for that product
  Then the user should see only the CAT 1 upload for c1

Scenario: View only CAT 3 Upload for C2
  When the user creates a product with tasks c2
  And the user views a product test for that product
  Then the user should see only the CAT 3 upload for c2

Scenario: View CAT 1 and CAT 3 Tabs
  When the user creates a product with tasks c1, c2
  And the user views a product test for that product
  Then the user should see CAT 1 and CAT 3 tabs for c1 and c2

Scenario: View CAT 1 and CAT 3 Tabs with C3
  When the user creates a product with tasks c1, c2, c3
  And the user views a product test for that product
  Then the user should see CAT 1 and CAT 3 tabs for c1, c2, and c3

Scenario: Successful Download CAT 1 Zip
  When the user creates a product with tasks c1
  And the user views a product test for that product
  And the user downloads the CAT 1 zip file
  Then the CAT 1 zip file should be downloaded

Scenario: Successful Upload CAT 1 Zip
  When the user creates a product with tasks c1
  And the user views a product test for that product
  And the user uploads a CAT 1 zip file
  Then the user should see test results