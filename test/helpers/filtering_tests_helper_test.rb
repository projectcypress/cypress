require 'test_helper'

class FilteringTestsHelperTest < ActiveSupport::TestCase
  include FilteringTestsHelper

  def setup
    collection_fixtures('health_data_standards_svs_value_sets')
    @filters = {
      providers: {
        npis: ['6892960108'],
        tins: ['1554520'],
        addresses: [{
          street: ['11 Sample Lane'],
          city: 'Sample City',
          state: 'SS',
          zip: '12345',
          country: 'US'
        }]
      },
      races: ['1002-5'],
      ethnicities: ['2135-2'],
      genders: ['F'],
      payers: ['Medicare'],
      problems: { oid: ['2.16.840.1.113883.3.464.1003.101.12.1022'] }
    }
  end

  def test_display_filter_val
    assert_equal display_filter_val('providers', @filters.providers), 'NPIS: 6892960108 | TINS: 1554520 | 11 Sample Lane, Sample City, SS, 12345, US'
    assert_equal display_filter_val('races', @filters.races), 'American Indian or Alaska Native (code: 1002-5)'
    assert_equal display_filter_val('ethnicities', @filters.ethnicities), 'Hispanic or Latino (code: 2135-2)'
    assert_equal display_filter_val('genders', @filters.genders), 'F'
    assert_equal display_filter_val('payers', @filters.payers), 'Medicare'
    assert_equal display_filter_val('problems', @filters.problems),
                 'Preventive Care- Initial Office Visit, 0 to 17 (code: 2.16.840.1.113883.3.464.1003.101.12.1022)'
  end

  def test_display_filter_val_age
    age_filter = {}
    age_filter['max'] = '21'
    assert_equal display_filter_val('age', age_filter), 'max: 21'

    age_filter['min'] = '18'
    assert_equal display_filter_val('age', age_filter), 'min: 18, max: 21'

    age_filter.except!('max')
    assert_equal display_filter_val('age', age_filter), 'min: 18'
  end
end
