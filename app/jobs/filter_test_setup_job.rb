# frozen_string_literal: true

class FilterTestSetupJob < ApplicationJob
  queue_as :filter_test_setup
  include Job::Status
  def perform(product)
    product = Product.find(product)
    add_filtering_tests(product)
  end

  def add_filtering_tests(product)
    measure = ApplicationController.helpers.pick_measure_for_filtering_test(product.measure_ids, product.bundle)
    product.reload_relations

    return if product.product_tests.filtering_tests.any?

    # TODO: R2P: check new criteria names
    criteria = %w[races ethnicities genders payers age].shuffle
    filter_tests = []
    filter_tests.push(build_filtering_test(product, measure, criteria[0, 2]), build_filtering_test(product, measure, criteria[2, 2]))
    filter_tests << build_filtering_test(product, measure, ['providers'], 'NPI, TIN & Provider Location')
    filter_tests << build_filtering_test(product, measure, ['providers'], 'NPI & TIN', incl_addr: false)
    criteria = ApplicationController.helpers.measure_has_snomed_dx_criteria?(measure) ? ['problems'] : criteria.values_at(4, (0..3).to_a.sample)
    filter_tests << build_filtering_test(product, measure, criteria)
    generate_filter_patients(filter_tests)
  end

  def build_filtering_test(product, measure, criteria, display_name = '', incl_addr: true)
    # construct options hash from criteria array and create the test
    options = { 'filters' => criteria.to_h { |c| [c, []] } }
    product.product_tests.create({ name: measure.description, product:, measure_ids: [measure.hqmf_id], cms_id: measure.cms_id,
                                   incl_addr:, display_name:, options: }, FilteringTest)
  end

  def generate_filter_patients(filter_tests)
    return unless filter_tests

    test = filter_tests.pop
    test.generate_patients
    test.save
    test.queued
    ProductTestSetupJob.perform_later(test)
    patients = test.patients
    filter_tests.each do |ft|
      patients.collect do |p|
        p2 = p.clone
        p2.correlation_id = ft.id
        p2.save
        p2
      end
      ft.save
      ft.queued
      ProductTestSetupJob.perform_later(ft)
    end
  end
end
