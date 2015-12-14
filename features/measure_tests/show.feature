Feature: Measure Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor
  And the user has selected a measure

Scenario: Successfully View a Measure Test
  When the user creates a product with tasks c1
  And the user views a product test for that product
  Then the user should see the upload functionality for that product test

Scenario: View Only C1 Execution Page
  When the user creates a product with tasks c1
  And the user views a product test for that product
  Then the user should only see the c1 execution page

Scenario: View Only C2 Execution Page
  When the user creates a product with tasks c2
  And the user views a product test for that product
  Then the user should only see the c2 execution page

Scenario: View C1 And C2 Execution Pages
  When the user creates a product with tasks c1, c2
  And the user views a product test for that product
  And the user switches to c2 certification
  Then the user should see the c2 execution page

Scenario: View C1 and C3 And C2 and C3 Execution Pages
  When the user creates a product with tasks c1, c2, c3
  And the user views a product test for that product
  And the user switches to c2 and c3 certification
  Then the user should see the c2 and c3 execution page

Scenario: Successful Download CAT 1 Zip
  When the user creates a product with tasks c1
  And the user views a product test for that product
  And the user downloads the CAT 1 zip file
  Then the CAT 1 zip file should be downloaded
  And the user should see no execution results

Scenario: Successful Upload CAT 1 Zip
  When the user creates a product with tasks c2
  And the user views a product test for that product
  And the user uploads a CAT 1 zip file
  Then the user should see test results

Scenario: Successful Upload CAT 3 XML
  When the user creates a product with tasks c2
  And the user views a product test for that product
  And the user uploads a CAT 3 XML file
  Then the user should see test results