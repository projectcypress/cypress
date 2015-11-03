Feature: C4 Testing

Scenario: User can access C4 Testing
  Given a signed in user
  Given a user has a vendor
  Given a vendor has a product
  When the user clicks on CQM Filtering
  Then the user should see a Create Test button

Scenario: User can create a C4 Test
  Given a signed in user
  Given a user has a vendor
  Given a vendor has a product
  When the user clicks on CQM Filtering
  When the user clicks the Create Test button
  Then the user should should see the filter modal


Scenario: User can create a C4 Test
  Given a signed in user
  Given a user has a vendor
  Given a vendor has a product
  When the user clicks on CQM Filtering
  When the user clicks the Create Test button
  When the user selects Race
  Then the secondary filter should not include Race
