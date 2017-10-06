Feature: Show All Records

Background:
  Given the user is signed in

Scenario: View Master Patient List Page
  When the user visits the records page
  Then the user should see a list of patients
  And the user should see a way to switch bundles
  And the user should see a way to filter patients
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: View Master Patient List Page, Deprecated Bundle
  When the user visits the records page
  And the default bundle has been deprecated
  Then the user should not see deprecated bundles

Scenario: View Master Patient List Page, Single Bundle
  When the user visits the records page
  And there is only 1 bundle installed
  Then the user should see a list of patients
  And the user should not see a way to switch bundles
  And the user should see a way to filter patients
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Download MPL from Master Patient List Page
  When the user visits the records page
  And the Master Patient List zip is not already built
  Then the user should see Preparing Download for all MPL downloads
  When the Master Patient List zip is ready for download
  Then the user should see a Download button
  When the user clicks a Download button
  Then a zip file should be downloaded

Scenario: Download MPL from Master Patient List Page, Single Bundle
  When the user visits the records page
  And there is only 1 bundle installed
  And the Master Patient List zip is not already built
  Then the user should see Preparing Download for all MPL downloads
  When the Master Patient List zip is ready for download
  Then the user should see a Download button
  When the user clicks a Download button
  Then a zip file should be downloaded

Scenario: Successful switch bundles
  When the user visits the records page
  And the user selects a bundle
  Then the user should see records for that bundle
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa

Scenario: Successful filter records
  When the user visits the records page
  And the user searches for a measure
  And the user selects a measure from the dropdown
  Then the user should see results for that measure
  Then the page should be accessible according to: section508
  Then the page should be accessible according to: wcag2aa
