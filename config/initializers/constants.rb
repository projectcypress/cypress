# These constants provide a mapping between Cypress's certifications and tests,
# as well as a single source for titles and descriptions

CERTIFICATIONS = {
  'C1' => {
    'title' => 'C1 Test - Record and Export',
    'description' => 'EHRs must be able to export a data file that includes all of the data captured for every tested CQM.',
    'tests' => %w(MeasureTest ChecklistTest)
  },
  'C2' => {
    'title' => 'C2 Test - Import and Calculate',
    'description' => 'EHR technology must be able to electronically import a data file and use such data to perform calculations.',
    'tests' => %w(MeasureTest)
  },
  'C3' => {
    'title' => 'C3 Test - Data Submission',
    'description' => 'EHRs must enable a user to electronically create a data file for transmission of clinical quality measurement data.',
    'tests' => %w(MeasureTest)
  },
  'C4' => {
    'title' => 'C4 Test - Data Filtering',
    'description' => 'EHRs must be able to filter patient records based on data criteria.',
    'tests' => %w(FilteringTest)
  }
}

TESTS = {
  'MeasureTest' => {
    'title' => 'Measure Tests',
    'description' => 'These tests can test the EHR system\'s ability to record, export, import, calculate, and submit measure-based data',
    'certifications' => %w(C1 C2 C3)
  },
  'FilteringTest' => {
    'title' => 'CQM Filtering Test',
    'description' => 'This tests the EHR system\'s ability to filter patient records.',
    'certifications' => %w(C4)
  },
  'ChecklistTest' => {
    'title' => 'Manual Entry Test',
    'description' => 'This test involves visual inspection of data entry.',
    'certifications' => %w(C1)
  }
}
