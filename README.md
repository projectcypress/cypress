Cypress
=========

[![GitHub version](https://badge.fury.io/gh/projectcypress%2Fcypress.svg)](https://badge.fury.io/gh/projectcypress%2Fcypress)
[![codecov](https://codecov.io/gh/projectcypress/cypress/branch/master/graph/badge.svg)](https://codecov.io/gh/projectcypress/cypress)

Cypress is the rigorous and repeatable testing tool of Electronic Health Records (EHRs) and EHR modules in calculating Electronic Clinical Quality Measures (eCQMs). The Cypress tool is open source and freely available for use or adoption by the health IT community including EHR vendors and testing labs. Cypress serves as the official testing tool for the 2015 EHR Certification program supported by the Office of the National Coordinator for Health IT (ONC).

Installing
-------

For the 2015 ONC Edition with the eCQMs updated for calendar year 2023 and 2024 reporting, use [Cypress 7](https://github.com/projectcypress/cypress/wiki/Cypress-7-Install-Instructions)


Docker deployment
-------

Using docker is the fastest way to stand up Cypress for deployment and development.

1. Review `docker-compose.yml` to configure environment variables

2. Spin up app with `docker compose up -d --build`

*NOTE: To spin up Cypress development environment, with hot-reloading enabled for code changes, run `docker compose -f docker-compose.dev.yml up -d`*

Reporting Issues
================
To report issues with alpha/beta releases, please submit tickets to [GitHub](https://github.com/projectcypress/cypress/issues)
To report issues with production releases, please submit tickets to [JIRA](https://oncprojectracking.healthit.gov/support/projects/CYPRESS/issues)

License
-------

Copyright 2011 The MITRE Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

