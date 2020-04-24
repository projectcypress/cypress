require 'test_helper'
class MeasureTestTest < ActiveJob::TestCase
  def setup
    @vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
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
    product = @vendor.products.create(name: 'test_product', c1_test: true, randomize_patients: true, duplicate_patients: true,
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
    perform_enqueued_jobs do
      product = @vendor.products.create(name: 'test_product_c1', c1_test: true, randomize_patients: true, duplicate_patients: true,
                                        bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
      pt = product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                         bundle_id: @bundle.id }, MeasureTest)
      pt.create_tasks
      assert pt.tasks.c1_task, 'product test should have a c1_task'
      assert_equal false, pt.tasks.c2_task, 'product test should not have a c2_task'
      assert_equal false, pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
      assert_equal false, pt.tasks.c3_cat3_task, 'product test should not have a c3_cat3_task'
      assert pt.save, 'should be able to save valid product test'
      assert_performed_jobs 1
      assert pt.patients.count.positive?, 'product test creation should have created random number of test records'
      pt.reload
      assert_not_nil pt.patient_archive, 'Product test should have archived patient records'
      assert_not_nil pt.html_archive, 'Product test should have archived patient HTMLs'
      # assert pt.patients.count < count_zip_entries(pt.patient_archive.file.path), 'Archive should contain more files than the test'
      pt.archive_patients
      assert count_zip_entries(pt.html_archive.file.path) == count_zip_entries(pt.patient_archive.file.path), 'QRDA Archive and HTML archive should have same # files'
      assert_not_nil pt.expected_results, 'Product test should have expected results'
    end
  end

  def test_create_without_randomized_records
    perform_enqueued_jobs do
      product = @vendor.products.create(name: 'test_product_no_random', c2_test: true, randomize_patients: false,
                                        bundle_id: @bundle.id, measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
      assert_enqueued_jobs 0
      pt = product.product_tests.build({ name: 'test_for_measure_1a', bundle_id: @bundle.id,
                                         measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
      assert pt.valid?, 'product test should be valid with product, name, and measure_id'
      assert pt.save, 'should be able to save valid product test'
      assert_performed_jobs 1
      assert_equal 9, pt.patients.count, 'product test creation should have created specific number of test records'
      patient = pt.patients.find_by(givenNames: ['ONE'], familyName: 'MPL record')
      assert_equal 'ONE', patient.givenNames[0], 'Patient name should not be randomized'
      assert_equal 'MPL record', patient.familyName, 'Patient name should not be randomized'
      assert_equal '1989db70-4d42-0135-8680-20999b0ed66f', patient.medical_record_number, 'Patient record # should not be randomized'

      pt.reload
      assert_not_nil pt.patient_archive, 'Product test should have archived patient records'
      assert_not_nil pt.html_archive, 'Product test should have archived patient HTMLs'
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

  def test_create_task_c3_creates_c2_also_for_ep_measure
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_create_task_c3_creates_c1_also_for_eh_measure
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['AE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert pt.tasks.c3_cat1_task, 'product test should have a c3_cat1_task'
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
    # should not have a c3_cat1_task for an EP measure
    assert_equal false, pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
    # should have a c3_cat3 task
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_create_task_c2_and_c3
    @product.c2_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    # should not have a c1_task, just no validators (for an EP measure)
    assert_equal false, pt.tasks.c1_task, 'product test should not have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    # should not have a c3_cat1 task for EP measure
    assert_equal false, pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_create_task_c1_c2_and_c3_ep_measure
    @product.c1_test = true
    @product.c2_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    # should not have a c3_cat1 task for EP measure
    assert_equal false, pt.tasks.c3_cat1_task, 'product test should not have a c3_cat1_task'
    assert pt.tasks.c3_cat3_task, 'product test should have a c3_cat3_task'
  end

  def test_create_task_c1_c2_and_c3_eh_measure
    @product.c1_test = true
    @product.c2_test = true
    @product.c3_test = true
    pt = @product.product_tests.build({ name: 'mtest', measure_ids: ['AE65090C-EB1F-11E7-8C3F-9A214CF093AE'] }, MeasureTest)
    pt.create_tasks
    assert pt.tasks.c1_task, 'product test should have a c1_task'
    assert pt.tasks.c2_task, 'product test should have a c2_task'
    assert pt.tasks.c3_cat1_task, 'product test should have a c3_cat1_task'
    # should not have a c3_cat3 task for EH measure
    assert_equal false, pt.tasks.c3_cat3_task, 'product test should not have a c3_cat3_task'
  end

  # Provider generation is now a before_validation hook on the MeasureTest model
  def test_generate_provider
    test = @product.product_tests.build({ name: "my measure test #{rand}", measure_ids: @product.measure_ids }, MeasureTest)
    test.save!
    assert_not_equal nil, test.reload.provider
  end
end
