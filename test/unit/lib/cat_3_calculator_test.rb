require 'test_helper'
require 'fileutils'

class Cat3CalculatorTest < ActiveSupport::TestCase
  setup do
    bundle = FactoryGirl.create(:static_bundle)
    @c3c = Cypress::Cat3Calculator.new(['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle)
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
    file = IO.read('test/fixtures/qrda/cat_I/good.xml')
    before_count = Record.count
    @c3c.import_cat1_file(file)
    assert_equal before_count + 1, Record.count
    assert_equal @c3c.correlation_id, Record.order_by(created_at: 'asc').last.test_id
  end

  def test_import_cat1_zip
    file = File.new('test/fixtures/qrda/cat_I/2_qrdas.zip')
    before_count = Record.count
    @c3c.import_cat1_zip(file)
    assert_equal before_count + 2, Record.count
  end

  def test_generate_cat3
    file = IO.read('test/fixtures/qrda/cat_III/ep_test_qrda_cat3_good.xml')
    QME::QualityReport.any_instance.stubs(:result).returns(@result)
    QME::QualityReport.any_instance.stubs(:calculated?).returns(true)
    HealthDataStandards::Export::Cat3.any_instance.stubs(:export).returns(file)
    record = FactoryGirl.create(:static_test_record)
    record.test_id = @c3c.correlation_id
    record.save
    cat3 = @c3c.generate_cat3
    assert cat3 == file
  end
end
