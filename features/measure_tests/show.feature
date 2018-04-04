Feature: Measure Test Executions

Background:
  Given the user is signed in
  And the user has created a vendor
  And the user has selected a measure

Scenario: Successfully View a Measure Test
  When the user creates a product with tasks c1
  And the user views task c1
  Then the user should see the upload functionality for that product test
  Then the user should see provider information
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View Only C1 Execution Page
  When the user creates a product with tasks c1
  And the user views task c1
  Then the user should only see the c1 execution page
  Then the user should see provider information
  And the user should be able to click eCQM Specification link
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View Only C2 Execution Page
  When the user creates a product with tasks c2
  And the user views task c2
  Then the user should only see the c2 execution page
  Then the user should see provider information
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View C1 And C2 Execution Pages
  When the user creates a product with tasks c1, c2
  And the user views task c1
  And the user switches to c2 certification
  Then the user should see the c2 execution page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View C1 and C3 And C2 and C3 Execution Pages
  When the user creates a product with tasks c1, c2, c3
  And the user views task c1
  And the user switches to c2 and c3 certification
  And the user should be able to click eCQM Specification link
  Then the user should see the c2 and c3 execution page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Download CAT 1 Zip
  When the user creates a product with tasks c1
  And the product test state is set to ready
  And the user views task c1
  Then the user should be able to download a CAT 1 zip file
  And the user should see no execution results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Cannot View Download CAT 1 Zip
  When the user creates a product with tasks c1
  And the product test state is not set to ready
  And the user views task c1
  Then the user should not be able to download a CAT 1 zip file
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Upload CAT 1 Zip
  When the user creates a product with tasks c1
  And the user views task c1
  And the user uploads a CAT 1 zip file
  Then the user should see test results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Upload CAT 3 XML
  When the user creates a product with tasks c2
  And the user views task c2
  And the user uploads a CAT 3 XML file
  Then the user should see test results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Upload CAT 1 Zip Because Incorrect File Type
  When the user creates a product with tasks c1
  And the user views task c1
  And the user uploads an invalid file
  Then the user should see an error message saying "Invalid file upload"
  And the user should see no execution results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Upload CAT 3 XML Because Incorrect File Type
  When the user creates a product with tasks c2
  And the user views task c2
  And the user uploads an invalid file
  Then the user should see an error message saying "Invalid file upload"
  And the user should see no execution results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful View Uploaded XML for Measure Test
  When the user creates a product with tasks c2
  And the user views task c2
  And the user uploads a CAT 3 XML file
  And the user waits for results then views task c2
  Then the user should see a link to view the the uploaded xml
  When the user views the uploaded xml
  Then the user should see the uploaded xml

Scenario: Successfully View a Measure Test on Deprecated Product
  When the user creates a product with tasks c1
  And the default bundle has been deprecated
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  Then the user should see the upload functionality for that product test
  Then the user should see provider information
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View Only C1 Execution Page on Deprecated Product
  When the user creates a product with tasks c1
  And the default bundle has been deprecated
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  Then the user should only see the c1 execution page
  Then the user should see provider information
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View Only C2 Execution Page on Deprecated Product
  When the user creates a product with tasks c2
  And the default bundle has been deprecated
  And the user views task c2
  Then the user should see a notification saying the product was deprecated
  Then the user should only see the c2 execution page
  Then the user should see provider information
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View C1 And C2 Execution Pages on Deprecated Product
  When the user creates a product with tasks c1, c2
  And the default bundle has been deprecated
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  And the user switches to c2 certification
  Then the user should see the c2 execution page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View C1 and C3 And C2 and C3 Execution Pages on Deprecated Product
  When the user creates a product with tasks c1, c2, c3
  And the default bundle has been deprecated
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  And the user switches to c2 and c3 certification
  Then the user should see the c2 and c3 execution page
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Download CAT 1 Zip on Deprecated Product
  When the user creates a product with tasks c1
  And the default bundle has been deprecated
  And the product test state is set to ready
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  Then the user should be able to download a CAT 1 zip file
  And the user should see no execution results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Cannot View Download CAT 1 Zip on Deprecated Product
  When the user creates a product with tasks c1
  And the default bundle has been deprecated
  And the product test state is not set to ready
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  Then the user should not be able to download a CAT 1 zip file
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Upload CAT 1 Zip on Deprecated Product
  When the user creates a product with tasks c1
  And the default bundle has been deprecated
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  And the user uploads a CAT 1 zip file
  Then the user should see test results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful Upload CAT 3 XML on Deprecated Product
  When the user creates a product with tasks c2
  And the default bundle has been deprecated
  And the user views task c2
  Then the user should see a notification saying the product was deprecated
  And the user uploads a CAT 3 XML file
  Then the user should see test results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Upload CAT 1 Zip Because Incorrect File Type on Deprecated Product
  When the user creates a product with tasks c1
  And the default bundle has been deprecated
  And the user views task c1
  Then the user should see a notification saying the product was deprecated
  And the user uploads an invalid file
  Then the user should see an error message saying "Invalid file upload"
  And the user should see no execution results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Unsuccessful Upload CAT 3 XML Because Incorrect File Type on Deprecated Product
  When the user creates a product with tasks c2
  And the default bundle has been deprecated
  And the user views task c2
  Then the user should see a notification saying the product was deprecated
  And the user uploads an invalid file
  Then the user should see an error message saying "Invalid file upload"
  And the user should see no execution results
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful View Uploaded XML for Measure Test on Deprecated Product
  When the user creates a product with tasks c2
  And the default bundle has been deprecated
  And the user views task c2
  Then the user should see a notification saying the product was deprecated
  And the user uploads a CAT 3 XML file
  And the user waits for results then views task c2
  Then the user should see a link to view the the uploaded xml
  When the user views the uploaded xml
  Then the user should see the uploaded xml
