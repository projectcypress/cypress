# frozen_string_literal: true

require 'test_helper'

class FilteringTestsHelperTest < ActiveSupport::TestCase
  include FilteringTestsHelper

  def setup
    @bundle = FactoryBot.create(:static_bundle)
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
      problems: { oid: ['1.5.6.7'] }
    }
  end

  def test_display_filter_val
    assert_equal display_filter_val('providers', @bundle.randomization, @filters.providers), [{ NPIs: '6892960108' }, { TINs: '1554520' }, { Addresses: '11 Sample Lane, Sample City, SS, 12345, US' }]
    assert_equal display_filter_val('races', @bundle.randomization, @filters.races), ['American Indian or Alaska Native (code: 1002-5)']
    assert_equal display_filter_val('ethnicities', @bundle.randomization, @filters.ethnicities), ['Hispanic or Latino (code: 2135-2)']
    assert_equal display_filter_val('genders', @bundle.randomization, @filters.genders), ['F']
    assert_equal display_filter_val('payers', @bundle.randomization, @filters.payers), ['Medicare']
    assert_equal display_filter_val('problems', @bundle.randomization, @filters.problems), ['SNOMEDCT codes in Value Set Name 5 (code: 1.5.6.7)']
  end

  def test_display_filter_val_age
    age_filter = {}
    age_filter['max'] = '21'
    assert_equal display_filter_val('age', @bundle.randomization, age_filter), [{ Maximum: '21' }]

    age_filter['min'] = '18'
    assert_equal display_filter_val('age', @bundle.randomization, age_filter), [{ Minimum: '18' }, { Maximum: '21' }]

    age_filter.except!('max')
    assert_equal display_filter_val('age', @bundle.randomization, age_filter), [{ Minimum: '18' }]
  end

  def test_display_filter_val_direct_reference
    vs = FactoryBot.create(:value_set, oid: 'drc-0123456', bundle: @bundle)
    assert_equal ['SNOMEDCT codes in Concept 1 (code: 6)'], display_filter_val('problems', @bundle.randomization, oid: [vs.oid])
  end
end
