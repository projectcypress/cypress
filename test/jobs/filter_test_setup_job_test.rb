# frozen_string_literal: true

require 'test_helper'

class FilterTestSetupJobTest < ActiveJob::TestCase
  def setup
    vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    @product = vendor.products.create(name: 'test_product', c4_test: true, randomize_patients: true, bundle_id: @bundle.id,
                                      measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
  end

  def test_generate_filter_patients
    perform_enqueued_jobs do
      FilterTestSetupJob.perform_now(@product.id.to_s)
    end
    patients = @product.product_tests.filtering_tests.find_by(cms_id: 'CMS32v7').patients
    @product.product_tests.filtering_tests.each do |ft|
      # each filtering test should share the same patients
      assert ft.patients.map { |p| "#{p.first_names} #{p.familyName}" } == patients.map { |p| "#{p.first_names} #{p.familyName}" }
    end
  end
end
