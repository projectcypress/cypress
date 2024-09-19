Feature: Show All Records

Background:
  Given the user is signed in

Scenario: View Master Patient List Page
  When the user visits the records page
  Then the user should see a list of patients
  And the user should see a way to switch bundles
  And the user should see a way to filter patients
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: View Master Patient List Page, Deprecated Bundle
  When the user visits the records page
  And the default bundle has been deprecated
  Then the user should not see deprecated bundles
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: View Master Patient List Page, Single Bundle
  When the user visits the records page
  And there is only 1 bundle installed
  Then the user should see a list of patients
  And the user should see a way to filter patients
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: Download MPL from Master Patient List Page
  When the user visits the records page
  And the Master Patient List zip is not already built
  Then the user should see Preparing Download for all MPL downloads
  When the Master Patient List zip is ready for download
  Then the user should see a Download button
  # TODO: bring this back later
  # When the user clicks a Download button
  # Then a zip file should be downloaded within 1 seconds
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Download MPL from Master Patient List Page, Single Bundle
  When the user visits the records page
  And there is only 1 bundle installed
  And the Master Patient List zip is not already built
  Then the user should see Preparing Download for all MPL downloads
  When the Master Patient List zip is ready for download
  Then the user should see a Download button
  # TODO: bring this back later
  # When the user clicks a Download button
  # Then a zip file should be downloaded within 1 seconds
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful switch bundles
  When the user visits the records page
  And the user selects a bundle
  Then the user should see records for that bundle
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful filter records
  When the user visits the records page
  And the user searches for a measure
  And the user selects a measure from the dropdown
  Then the user should see results for that measure
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: View Vendor Patient List Page
  When the user visits the vendor records page
  Then the user should see a list of vendor patients
  And the user should see a way to switch bundles
  And the user should see a way to filter patients
  And the user should see a way to select all patients
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: View Vendor Patient List Analyize Page
  When the user visits the vendor records page
  Then the user should see a list of vendor patients
  And the user should see a way to analyize patients
  And the user views patient analytics
  And the user should see patient analytics
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa; skipping: color-contrast
  And the driver is returned to the default

Scenario: Successful switch bundles for vendor patients
  When the user visits the vendor records page
  And the user selects a bundle
  Then the user should see records for that bundle
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: Successful filter records for vendor patient
  When the user visits the vendor records page
  Then the user should see a list of vendor patients
  And the user searches for a measure
  And the user selects a measure from the dropdown
  Then the user should see results for that measure
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  

Scenario: View Vendor Patient Page
  Given a vendor patient has measure_calculations
  When the user visits the vendor patient link
  Then the user should see vendor patient details
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default

Scenario: Scoop and Filter Vendor Patient Page
  Given a vendor patient has measure_calculations
  When the user visits the vendor patient link
  When the user filters on CMS32v7
  Then the user should see text EncounterPerformed
  When the user filters on CMS032v7
  Then the user should not see text EncounterPerformed
  Then the user should see text PatientCharacteristicBirthdate
  When the user filters on All Measures
  Then the user should see text EncounterPerformed
  And the driver is setup for accessability testing
  Then the page should be axe clean according to: section508
  Then the page should be axe clean according to: wcag2aa
  And the driver is returned to the default  
