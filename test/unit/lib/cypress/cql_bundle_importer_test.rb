require 'test_helper'

class CqlBundleImporterTest < ActiveSupport::TestCase
  setup do
    @bundle = FactoryBot.create(:static_bundle)
    @fake_bundle_dir = Dir.new File.join('test', 'fixtures', 'bundles', 'measures_only_bundle')
  end

  test 'should successfully unpack measures out of bundle' do
    before_count = Measure.count()
    Cypress::CqlBundleImporter.unpack_and_store_valuesets(@fake_bundle_dir, @bundle)
    Cypress::CqlBundleImporter.unpack_and_store_measures(@fake_bundle_dir, @bundle)
    assert_equal (before_count + 2), Measure.count()
  end

  test 'should successfully unpack valuesets out of bundle' do
    before_count = ValueSet.count()
    Cypress::CqlBundleImporter.unpack_and_store_valuesets(@fake_bundle_dir, @bundle)
    assert_equal (before_count + 22), ValueSet.count()
  end

  test 'should successfully unpack patients out of bundle' do
    before_count = Patient.count()
    Cypress::CqlBundleImporter.unpack_and_store_cqm_patients(@fake_bundle_dir, @bundle)
    assert_equal (before_count + 1), Patient.count()
  end
end