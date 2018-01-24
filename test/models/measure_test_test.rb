require 'test_helper'
class MeasureTestTest < ActiveJob::TestCase
  def setup
    @vendor = FactoryGirl.create(:vendor)
    @bundle = FactoryGirl.create(:static_bundle)
    @product = @vendor.products.create(name: 'test_product', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'], bundle_id: @bundle.id)
  end

  # def test_more_than_one_measure
  #   pt = @product.product_tests.build({ name: 'mtest', measure_ids: %w(8A4D92B2-397A-48D2-0139-C648B33D5582 0002) }, MeasureTest)
  #   assert_equal false,  pt.valid?, 'product test should not be valid without a '
  #   assert_equal false,  pt.save, 'should not be able to save product test with more than 1 measure id'
  #   errors = pt.errors
  #   assert errors.key?(:measure_ids)
  # end

  def test_single_measure
    product = @vendor.products.create(name: 'test_product', c1_test: true, randomize_records: true, duplicate_records: true,
                                      bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    pt = product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                       bundle_id: @bundle.id }, MeasureTest)
    assert_equal true,  pt.valid?, 'product test should be valid with single measure id'
    assert_equal true,  pt.save, 'should save with single measure id'
  end

  def count_zip_entries(path)
    count = 0
    Zip::ZipFile.open(path) do |z|
      count = z.entries.length
    end
    count
  end

  def test_create_task_c1
    product = @vendor.products.create(name: 'test_product', c1_test: true, randomize_records: true, duplicate_records: true,
                                      bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    pt = product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                       bundle_id: @bundle.id }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert_equal false, pt.tasks.c2_task, 'product test should not have a c2_task'
    assert_equal false, pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
    assert_equal false, pt.tasks.c3_cat3_task, 'product test should not have a c3_cat3_task'
    perform_enqueued_jobs do
      assert pt.save, 'should be able to save valid product test'
      assert_performed_jobs 1
      assert pt.records.count.positive?, 'product test creation should have created random number of test records'
      pt.reload
      assert_not_nil pt.patient_archive, 'Product test should have archived patient records'
      assert_not_nil pt.html_archive, 'Product test should have archived patient HTMLs'
      assert pt.records.count < count_zip_entries(pt.patient_archive.file.path), 'Archive should contain more files than the test'
      assert count_zip_entries(pt.html_archive.file.path) == count_zip_entries(pt.patient_archive.file.path), 'QRDA Archive and HTML archive should have same # files'
      assert_not_nil pt.expected_results, 'Product test should have expected results'
    end
  end

  def test_create_without_randomized_records
    product = @vendor.products.create(name: 'test_product_no_random', c2_test: true, randomize_records: false,
                                      bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    assert_enqueued_jobs 0
    pt = product.product_tests.build({ name: 'test_for_measure_1a', bundle_id: @bundle.id,
                                       measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    assert pt.valid?, 'product test should be valid with product, name, and measure_id'
    perform_enqueued_jobs do
      assert pt.save, 'should be able to save valid product test'
      assert_performed_jobs 1
      assert_equal 1, pt.records.count, 'product test creation should have created specific number of test records'
      patient = pt.records.find_by(first: 'Selena')
      assert_equal 'Selena', patient.first, 'Patient name should not be randomized'
      assert_equal 'Lotherberg', patient.last, 'Patient name should not be randomized'
      assert_equal '0989db70-4d42-0135-8680-20999b0ed66f', patient.medical_record_number, 'Patient record # should not be randomized'

      pt.reload
      assert_not_nil pt.patient_archive, 'Product test should have archived patient records'
      assert_not_nil pt.html_archive, 'Product test should have archived patient HTMLs'
      assert count_zip_entries(pt.html_archive.file.path) == count_zip_entries(pt.patient_archive.file.path), 'QRDA Archive and HTML archive should have same # files'
      assert_not_nil pt.expected_results, 'Product test should have expected results'
    end
  end

  def test_create_task_2014_edition
    product = @vendor.products.create(name: 'test_product', c1_test: true, randomize_records: true, cert_edition: '2014',
                                      bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    pt = product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                       bundle_id: @bundle.id }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert_equal false, pt.tasks.cat1_filter_task, 'product test for 2014 certification should not have a C4 task'
    assert_equal false, pt.tasks.cat3_filter_task, 'product test for 2014 certification should not have a C4 task'

    perform_enqueued_jobs do
      assert pt.save, 'should be able to save valid product test'
      assert_performed_jobs 1
      assert pt.records.count.positive?, 'product test creation should have created random number of test records'
      assert pt.records.count < 10, 'product tests for 2014 editions should have fewer than 10 records'
      pt.reload
      assert_not_nil pt.patient_archive, 'Product test should have archived patient records'
      assert_not_nil pt.html_archive, 'Product test should have archived patient HTMLs'
      assert_equal pt.records.count, count_zip_entries(pt.patient_archive.file.path), 'Archive should contain more files than the test'
      assert count_zip_entries(pt.html_archive.file.path) == count_zip_entries(pt.patient_archive.file.path), 'QRDA Archive and HTML archive should have same # files'
      assert_not_nil pt.expected_results, 'Product test should have expected results'
    end
  end

  def test_create_task_c2
    @product.c2_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert_equal false, pt.tasks.c1_task, 'product test should not have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    assert_equal false, pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
    assert_equal false, pt.tasks.c3_cat3_task, 'product test should not have a c3_cat3_task'
  end

  def test_create_task_c3_creates_c1_and_c2_also
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    assert pt.tasks.c3_cat1_task, 'product test should have a c3_cat1_task'
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_create_task_c1_and_c2
    @product.c1_test = true
    @product.c2_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    assert_equal false, pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
    assert_equal false, pt.tasks.c3_cat3_task, 'product test should not have a c3_cat3_task'
  end

  def test_create_task_c1_and_c3
    @product.c1_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    # should have a c2_task, just no validators
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    assert pt.tasks.c3_cat1_task, 'product test should have a c3_cat1_task'
    # should have a c3_cat3 task
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_create_task_c2_and_c3
    @product.c2_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    # should have a c1_task, just no validators
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    # should have a c3_cat1 task
    assert pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_create_task_c1_c2_and_c3
    @product.c1_test = true
    @product.c2_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    assert pt.tasks.c3_cat1_task, 'product test should have a c3_cat1_task'
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_generate_provider
    test = @product.product_tests.build({ name: "my measure test #{rand}", measure_ids: @product.measure_ids }, MeasureTest)
    test.generate_provider

    test.reload
    assert_not_equal nil, test.provider
  end
end
