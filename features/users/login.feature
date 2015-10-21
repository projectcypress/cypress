Feature: Login

Scenario: Unsuccessful login
    Given a user has an account
    When the user tries to log in with invalid information
    Then the user should see an log in error message

Scenario: Successful login
   Given a user has an account
   When the user logs in
   Then the user should see an log in success message
   And the user should see a sign out link

Scenario: Successful logout
   Given a signed in user
   Then the user logs out
   And the user should see an log out success message

Scenario: Edit password
   Given a signed in user
   Then the user should click an account link
   And the user should see an edit account page
