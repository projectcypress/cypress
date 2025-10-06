Feature: Edit Application Settings
  Background:
    Given the user is signed in
    And the user is an admin

  Scenario: Admin updates Custom Mode Options
    When the user navigates to the admin page
    And the user clicks edit application settings
    And the user selects mode "custom"
    And the user sets auto approve to "enable"
    And the user sets ignore roles to "disable"
    And the user sets debug features to "disable"
    And the user selects default role "user"
    And the user submits the settings form
    Then the application settings in the database should be:
      | auto_approve   | true |
      | ignore_roles   | false |
      | debug_features | false |
      | default_role   | user |
