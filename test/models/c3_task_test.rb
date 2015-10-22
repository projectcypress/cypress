require 'test_helper'
class C3TaskTest < MiniTest::Test
  include ::Validators

  def setup
    collection_fixtures('product_tests','products', 'bundles', 
                        'measures','records','patient_cache')
  end

  def after_teardown
    drop_database
  end


  def test_create
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    assert ptest.tasks.create({}, C3Task)
  end

  def test_validators
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({}, C3Task)
    assert 3, task.validators.length
    assert task.validators.find { |v| v.class == QrdaCat3Validator }, 'Should have QrdaCat3Validator'
    assert task.validators.find { |v| v.class == ExpectedResultsValidator }, 'Should have ExpectedResultsValidator'
    assert task.validators.find { |v| v.class == MeasurePeriodValidator }, 'Should have MeasurePeriodValidator '
  end

  def test_execute
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml =create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_good.xml', 'application/xml')
    te = task.execute(xml)
    assert te.execution_errors.empty?, 'should be no errors for good cat I archive'
  end

  def test_should_error_when_measure_period_is_wrong
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_mp.xml', 'application/xml')
    te = task.execute(xml)
    assert_equal 2, te.execution_errors.length, 'should have 2 errors for the invalid reporting period'
  end

  def test_should_cause_error_when_stratifications_are_missing
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file( 'test/fixtures/qrda/ep_test_qrda_cat3_missing_stratification.xml' , 'application/xml')
    te = task.execute(xml)
    # Missing strat for the 1 numerator that has data
    assert_equal 1, te.execution_errors.length, 'should error on missing stratifications'
  end

  def test_should_cause_error_when_supplemental_data_is_missing
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_supplemental.xml','application/xml')
    te = task.execute(xml)
    # checked 3 times for each numerator -- we should do something about that
    assert_equal 3, te.execution_errors.length, 'should error on missing supplemetnal data'
  end

  def test_should_cause_error_when_not_all_populations_are_accounted_for
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file( 'test/fixtures/qrda/ep_test_qrda_cat3_missing_stratification.xml' , 'application/xml')
    te = task.execute(xml)

    assert_equal 1, te.execution_errors.length, 'should error on missing populations'
  end

  def test_should_cause_error_when_the_schema_structure_is_bad
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_bad_schematron.xml' , 'application/xml')
    te = task.execute(xml)
    # 3 errors 1 for schema validation and 2 schematron issues for realmcode
    assert_equal 3, te.execution_errors.length, 'should error on bad schematron'
  end

  def test_should_cause_error_when_measure_is_not_included_in_report
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_missing_measure.xml' , 'application/xml')
    te = task.execute(xml)
    # 9 is for all of the sub measures to be searched for 
    # 2 is for having incorrect measure Ids 
    # 2 for missing supplemental data
    assert_equal 23, te.execution_errors.length, 'should error on missing measure entry'
  end

  def test_should_cause_error_when_extra_supplemental_data_is_provided
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file( 'test/fixtures/qrda/ep_test_qrda_cat3_extra_supplemental.xml' , 'application/xml')
    te = task.execute(xml)
    # 1 Error for additional Race
    assert_equal 1, te.execution_errors.length, 'should error on additional supplemental data'
  end

  def test_should_not_cause_error_when_extra_supplemental_data_provided_has_zero_value
    ptest = ProductTest.find('51703a6a3054cf8439000044')
    task = ptest.tasks.create({ expected_results: ptest.expected_results }, C3Task)
    xml = create_rack_test_file('test/fixtures/qrda/ep_test_qrda_cat3_extra_supplemental_is_zero.xml', 'application/xml')
    te = task.execute(xml)
    assert te.execution_errors.empty?, 'should not error on additional supplemental data value equal to 0'
  end
end
