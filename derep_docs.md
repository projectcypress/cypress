# Background
## Prior Work
The Data Element Repository (DERep) Exporter contained in this repository was originally intended to export the data elements to text files in the [Clinical Information Modeling Profiling Language (CIMPL)](http://standardhealthrecord.org/cimpl-doc/) format used by the [Standard Health Record (SHR) Project](http://standardhealthrecord.org/). This took advantage of existing tooling for the SHR project, which was used to create a "Javadoc-like" webpage for the DERep. Over time, this approach evolved to create static HTML files for each data element, which could be imported into the eCQI Resource Center (eCQI RC) Drupal 7 instance.

## Drupal 8 Transition
The eCQI RC Drupal 8 transition provided an opportunity to migrate the current DERep generation and import process from generating static HTML files to creating native Drupal 8 entities. This allows for a much more integrated user experience, as well as much more flexibility in DERep display, searching/filtering, and creation/updating. The creation of this Drupal 8 "New Data Element" content type is discussed at length in Michael Nosal's documentation.

## New Exporter
The DERep Drupal 8 Exporter was modified to export the required data elements and related values to Drupal 8 from the Cypress database and related files. To accomplish this, the Exporter makes use of the [Drupal 8 JSON API module](https://www.drupal.org/docs/8/modules/jsonapi/api-overview). This module provides an Application Programming Interface (API) to Drupal 8 that follows the [JSON API specification](https://jsonapi.org/) for message types, formatting, and responses. Authentication is accomplished using the [HTTP Basic Auth Drupal Core module](https://www.drupal.org/docs/8/core/modules/basic_auth).

# Data Sources
* Measures
  * Measure data for the DERep comes from the MAT Export Packages hosted by the eCQI RC. The process of converting this data into a format useable by the DERep exporter is described in the [Measure Data](#measure-data) section below.
* Value Sets
  * Value set data for the DERep comes from the Value Set Authority Center (VSAC) Downloadable "All eCQM Value Sets (Eligible Professionals, Clinicians and Hospitals)" files, in "SVS (Text)" format. These files are pipe-separated, so they are imported into Excel and re-exported as comma-separated value (CSV) files. These files can be found at https://vsac.nlm.nih.gov/download/ecqm (UMLS Credentials are required for login).
    * Note: The 2019 Reporting/Performance Period DERep makes use of a set of updates made to the VSAC entries in March of 2019, provided to us in Excel format by the measure developers/VSAC. This file was de-duplicated, and exported to the same CSV format used by the DERep exporter. A copy of this file will be provided with the exporter tooling.
## Measure Data
### 2019
2019 Reporting/Performance Period measures were imported into the Bonnie tool, where Cypress's synthetic test patients were created. After this, the measures, patients, value sets (not used by the DERep) and results (not used by the Data Element Repository) were exported from Bonnie in an internally-used format into a "measure bundle" .zip file. This bundle can be downloaded and imported into Cypress version 4. This bundle is available at https://cypressdemo.healthit.gov/measure_bundles/bundle-2018.zip (UMLS Credentials are required for login).

### 2020
Similarly to 2019, 2020 Reporting/Performance Period measures were imported into the Bonnie tool, where Cypress's synthetic test patients were created. After this, the measures, patients, value sets (not used by the Data Element Repository) and results (not used by the Data Element Repository) were exported from Bonnie into a "measure bundle" .zip file. The measures remain in their MAT Export package .zip file format, while all other components use a similar export format to 2019. This bundle can be downloaded and imported into Cypress version 5. This bundle is available at https://cypressdemo.healthit.gov/measure_bundles/bundle-2019.zip (UMLS Credentials are required for login).
# Exporter Setup
## 2019 Measures
The Exporter for the 2019 measures is based off of Cypress v4. The branch containing the Exporter is called `generate_cimpl_d8`. To set it up, follow the instructions at https://github.com/projectcypress/cypress/wiki/Cypress-4-Install-Instructions, including the [bundle installation instructions](https://github.com/projectcypress/cypress/wiki/Cypress-4-Initial-Setup) (UMLS Credentials will be required to download the bundle). Then, change branches to `generate_cimpl_d8` by executing the command `git checkout generate_cimpl_d8` in the Cypress folder.
## 2020 Measures
The Exporter for the 2020 measures is based off of Cypress v5. The branch containing the Exorter is called `generate_cimpl_d8_2020`. To set it up, follow the instructions at https://github.com/projectcypress/cypress/wiki/Cypress-5-Install-Instructions, including the [bundle installation instructions](https://github.com/projectcypress/cypress/wiki/Cypress-5-Initial-Setup) (UMLS Credentials will be required to download the bundle). Then, change branches to `generate_cimpl_d8_2020` by executing the command `git checkout generate_cimpl_d8_2020` in the Cypress folder.
## Exporter Options
Several options must be set in each branch of the Exporter prior to running, to configure the Exporter for the environment to which it is exporting:
* `BASE_URL` is the URL of the Drupal 8 instance being loaded with DERep elements (e.g. `https://ecqi-dev.dd:8083/`)
* `USER` is the username of a Drupal user with sufficient permissions to create the DERep objects
* `@data_element_version` is the version of the Data Elements being exported, in [Semantic Versioning](https://semver.org/) format (e.g. `0.5.1`)
# Exporter Running
To run the exporter
