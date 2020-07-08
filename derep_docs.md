# Background
## Prior Work
The Data Element Repository (DERep) Exporter contained in this repository was originally intended to export the data elements to text files in the [Clinical Information Modeling Profiling Language (CIMPL)](http://standardhealthrecord.org/cimpl-doc/) format used by the [Standard Health Record (SHR) Project](http://standardhealthrecord.org/). This took advantage of existing tooling for the SHR project, which was used to create a "Javadoc-like" webpage for the DERep. Over time, this approach evolved to create static HTML files for each data element, which could be imported into the eCQI Resource Center (eCQI RC) Drupal 7 instance.

## Drupal 8 Transition
The eCQI RC Drupal 8 transition provided an opportunity to migrate the current DERep generation and import process from generating static HTML files to creating native Drupal 8 entities. This allows for a much more integrated user experience, as well as much more flexibility in DERep display, searching/filtering, and creation/updating. The creation of this Drupal 8 "New Data Element" content type is discussed at length in Michael Nosal's documentation.

## New Exporter
The DERep Drupal 8 Exporter was modified to export the required data elements and related values to Drupal 8 from the Cypress database and related files. To accomplish this, the Exporter makes use of the [Drupal 8 JSON API module](https://www.drupal.org/docs/8/modules/jsonapi/api-overview). This module provides an Application Programming Interface (API) to Drupal 8 that follows the [JSON API specification](https://jsonapi.org/) for message types, formatting, and responses. Authentication is accomplished using the [HTTP Basic Auth Drupal Core module](https://www.drupal.org/docs/8/core/modules/basic_auth).

# Data Sources

## Value Sets
* Value set data for the DERep comes from the Value Set Authority Center (VSAC) Downloadable "All eCQM Value Sets (Eligible Professionals, Clinicians and Hospitals)" files, in "SVS (Text)" format. These files are pipe-separated, so they are imported into Excel and re-exported as comma-separated value (CSV) files. These files can be found at https://vsac.nlm.nih.gov/download/ecqm (UMLS Credentials are required for login).
    * Note: The 2019 Reporting/Performance Period DERep makes use of a set of updates made to the VSAC entries in March of 2019, provided to us in Excel format by the measure developers/VSAC. This file was de-duplicated, and exported to the same CSV format used by the DERep exporter. A copy of this file will be provided with the exporter tooling.

## Measure Data
### 2019
2019 Reporting/Performance Period measures were downloaded as Measure Authoring Tool (MAT) export files, then imported into the Bonnie tool, where Cypress's synthetic test patients were created. After this, the measures, patients, value sets (not used by the DERep) and results (not used by the Data Element Repository) were exported from Bonnie in an internally-used format into a "measure bundle" .zip file. This bundle can be downloaded and imported into Cypress version 4. This bundle is available at https://cypressdemo.healthit.gov/measure_bundles/bundle-2018.zip (UMLS Credentials are required for login).

### 2020
Similar to 2019, 2020 Reporting/Performance Period measures were downloaded as Measure Authoring Tool (MAT) export files, then imported into the Bonnie tool, where Cypress's synthetic test patients were created. After this, the measures, patients, value sets (not used by the Data Element Repository) and results (not used by the Data Element Repository) were exported from Bonnie into a "measure bundle" .zip file. The measures remain in their MAT Export package .zip file format, while all other components use a similar export format to 2019. This bundle can be downloaded and imported into Cypress version 5. This bundle is available at https://cypressdemo.healthit.gov/measure_bundles/bundle-2019.zip (UMLS Credentials are required for login).

### 2021
#### Measures
Similar to 2020, 2021 Reporting/Performance Period measures were downloaded as Measure Authoring Tool (MAT) export files, then imported into the Bonnie tool, where Cypress's synthetic test patients were created. After this, the measures, patients, value sets (not used by the Data Element Repository) and results (not used by the Data Element Repository) were exported from Bonnie into a "measure bundle" .zip file. The measures remain in their MAT Export package .zip file format. This bundle can be downloaded and imported into Cypress version 6. This bundle is available at https://cypressdemo.healthit.gov/measure_bundles/bundle-2019.zip (UMLS Credentials are required for login).

#### QDM Categories
For 2021, the "QDM Category" Descriptions are taken from the [QDM 5.5 May 2020 Guidance Update PDF](https://ecqi.healthit.gov/sites/default/files/QDM-v5.5-Guidance-Update-May-2020-508.pdf). The descriptions are located in section 4.3, "Attributes", which begins on page 55 of the above PDF. The descriptions are translated by hand into HTML in order to best replicate the formatting of the descriptions in the PDF document. `<p></p>` tags are used to delineate distinct paragraphs in a description. `<ul></ul>` and `<li></li>` tags are used for bulleted lists (with additional formatting to change the bullet type for nested lists, as required, such as `<ul style=""list-style-type: '- ';"">`). Any double-quotes required in the description must be "escaped" by adding a second double-quote, as you can see in the `ul` example above. These descriptions are listed in a comma-separated value (CSV) file in `<cypress_root>/script/noversion`, entitled `qdm_categories.csv`. Column 1 is the title of the QDM Category; Column 2 is the HTML-ified description as listed above.

#### QDM Attributes
For 2021, the "QDM Attribute" Descriptions are taken from the [QDM 5.5 May 2020 Guidance Update PDF](https://ecqi.healthit.gov/sites/default/files/QDM-v5.5-Guidance-Update-May-2020-508.pdf). The descriptions are located in section 4.1, "Categories and Datatypes", which begins on page 21 of the above PDF. The descriptions are translated by hand into HTML in order to best replicate the formatting of the descriptions in the PDF document. `<p></p>` tags are used to delineate distinct paragraphs in a description. `<ul></ul>` and `<li></li>` tags are used for bulleted lists (with additional formatting to change the bullet type for nested lists, as required, such as `<ul style=""list-style-type: '- ';"">`). Any double-quotes required in the description must be "escaped" by adding a second double-quote, as you can see in the `ul` example above. These descriptions are listed in a comma-separated value (CSV) file in `<cypress_root>/script/noversion`, entitled `qdm_attributes.csv`. Column 1 is the title of the QDM Attribute; Column 2 is the HTML-ified description as listed above.

# Exporter Setup
## 2019 Measures
The Exporter for the 2019 measures is based off of Cypress v4. The branch containing the Exporter is called `generate_cimpl_d8`. To set it up, change branches to `generate_cimpl_d8` by executing the command `git checkout generate_cimpl_d8` in the Cypress folder. Then, follow the instructions at https://github.com/projectcypress/cypress/wiki/Cypress-4-Install-Instructions, including the [bundle installation instructions](https://github.com/projectcypress/cypress/wiki/Cypress-4-Initial-Setup) (UMLS Credentials will be required to download the bundle). 

Things that need to get run in the Terminal for Cypress v4 to install a Measure Bundle
* (In the Cypress directory): `bundle exec rails server`
* (In the Cypress directory): `bundle exec rake jobs:work`
* (In the js-ecqm-engine directory): `./bin/rabbit_worker.js`

Note: The rails server, the job worker, and the `js-ecqm-engine` referenced above do not need to be running in order to run the Drupal 8 exporter. The only running service needed for the Drupal 8 exporter to work is the MongoDB server.

## 2020 Measures
The Exporter for the 2020 measures is based off of Cypress v5. The branch containing the Exporter is called `generate_cimpl_d8_2020`. To set it up, change branches to `generate_cimpl_d8_2020` by executing the command `git checkout generate_cimpl_d8_2020` in the Cypress folder. Then, follow the instructions at https://github.com/projectcypress/cypress/wiki/Cypress-5-Install-Instructions, including the [bundle installation instructions](https://github.com/projectcypress/cypress/wiki/Cypress-5-Initial-Setup) (UMLS Credentials will be required to download the bundle).

Things that need to get run in the Terminal for Cypress v5 to install a Measure Bundle
* (In the Cypress directory): `bundle exec rails server`
* (In the Cypress directory): `bundle exec rake jobs:work`
* (In the cqm-execution-service directory): `yarn start`

Note: The rails server, the job worker, and the `cqm-execution-service` referenced above do not need to be running in order to run the Drupal 8 exporter. The only running service needed for the Drupal 8 exporter to work is the MongoDB server.

## 2021 Measures
The Exporter for the 2020 measures is based off of Cypress v6. The branch containing the Exporter is called `derep_2021`. To set it up, change branches to `derep_2021` by executing the command `git checkout derep_2021` in the Cypress folder. Then, follow the instructions at https://github.com/projectcypress/cypress/wiki/Cypress-6-Install-Instructions, including the [bundle installation instructions](https://github.com/projectcypress/cypress/wiki/Cypress-6-Initial-Setup) (UMLS Credentials will be required to download the bundle).

Things that need to get run in the Terminal for Cypress v5 to install a Measure Bundle
* (In the Cypress directory): `bundle exec rails server`
* (In the Cypress directory): `bundle exec rake jobs:work`
* (In the cqm-execution-service directory): `yarn start`

Note: The rails server, the job worker, and the `cqm-execution-service` referenced above do not need to be running in order to run the Drupal 8 exporter. The only running service needed for the Drupal 8 exporter to work is the MongoDB server.

## Exporter Options
Several options must be supplied to the exporter in order for it to work.
* JSON options should be specified in a JSON file and passed to the ruby program as the only argument. If these are not passed, they will be prompted for on the command line at run time.
    * `base_url` is the URL of the Drupal 8 instance being loaded with DERep elements (e.g. `https://ecqi-dev.dd:8083/`)
    * `username` is the username of a Drupal user with sufficient permissions to create the DERep objects
    * `data_element_version` is the version of the Data Elements being exported, in [Semantic Versioning](https://semver.org/) format (e.g. `0.5.1`)
* The only non-JSON option is the Drupal user's password, which cannot be supplied via the JSON file for security reasons, and which must be input at run time.

# Exporter Running
To run the exporter:
* 2019:
    * In the Cypress directory, execute the command `bundle exec ruby script/export_to_drupal.rb <path_to_json_file>.json`
* 2020
    * In the Cypress directory, execute the command `rails runner script/export_to_drupal.rb <path_to_json_file>.json`
Note: the JSON file path is relative to the cypress root directory.
