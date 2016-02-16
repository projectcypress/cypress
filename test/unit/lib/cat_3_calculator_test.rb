require 'test_helper'
require 'fileutils'

class Cat3CalculatorTest < ActiveSupport::TestCase
  setup do
    collection_fixtures('bundles', 'measures', 'records', 'health_data_standards_svs_value_sets')
    bundle = Bundle.find(BSON::ObjectId.from_string('4fdb62e01d41c820f6000001'))
    @c3c = Cypress::Cat3Calculator.new(['8A4D92B2-397A-48D2-0139-7CC6B5B8011E'], bundle)
    @result = QME::QualityReportResult.new(DENOM: 48, NUMER: 44, antinumerator: 4, DENEX: 0)
  end

  def test_generate_header
    header = @c3c.generate_header
    assert_instance_of Qrda::Header, header
    assert_instance_of Qrda::Id, header.identifier
    assert_equal 'CypressExtension', header.identifier.extension
    assert_equal 1, header.authors.length
    assert_instance_of DateTime, header.time
  end

  def test_import_cat1_file
    file = IO.read('test/fixtures/qrda/cat_1/good.xml')
    before_count = Record.count
    @c3c.import_cat1_file(file)
    assert_equal before_count + 1, Record.count
    assert_equal @c3c.correlation_id, Record.order_by(created_at: 'asc').last.test_id
  end

  def test_import_cat1_zip
    file = File.new('test/fixtures/qrda/cat_1/2_qrdas.zip')
    before_count = Record.count
    @c3c.import_cat1_zip(file)
    assert_equal before_count + 2, Record.count
  end

  def test_generate_cat3
    file = IO.read('test/fixtures/qrda/ep_test_qrda_cat3_good.xml')
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
    HealthDataStandards::Export::Cat3.any_instance.stubs(:export).returns(file)
    record = Record.find(BSON::ObjectId.from_string('4efa05ada9ffcce9010000dc'))
    record.test_id = @c3c.correlation_id
    record.save
    cat3 = @c3c.generate_cat3
    assert cat3 == file
  end
end
