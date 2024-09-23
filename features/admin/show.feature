Feature: Show Admin

Background:
  Given the user is signed in

Scenario: User is admin
  When the user is an admin
  And the user navigates to the admin page
  Then the user should be able to access the page
  And the driver is setup for accessability testing
  # Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: User can edit settings
  When the user is an admin
  And the user navigates to the admin page
  And the user clicks edit application settings
  And the driver is setup for accessability testing
  # Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: User can upload bundle
  When the user is an admin
  And the user navigates to the admin page
  And the user clicks bundles
  And the user clicks import bundle
  Then the user should be able to import bundle
  And the driver is setup for accessability testing
  # Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: User is not an admin
  When the user is not an admin
  And the user navigates to the admin page
  Then the user should not be able to access the page

Scenario: User can view bundles to download
  And the user navigates to the bundle_downloads page
  Then the user should see text bundle-2022
  Then the user should see text bundle-2023

# Why are you crashing the demoserver
# Scenario: User can not download bundle without NLM account
  # And the user navigates to the bundle_downloads page
  # Then the user selects bundle to download
  # And the user clicks download bundle
  # Then the user should see text Could not verify NLM User Account
  # # Then the page should be axe clean according to: section508
  # Then the page should be axe clean according to: wcag2aa
