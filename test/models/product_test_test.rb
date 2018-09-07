require 'test_helper'

class ProductTestTest < ActiveJob::TestCase
  def setup
    @vendor = FactoryBot.create(:vendor)
    @bundle = FactoryBot.create(:static_bundle)
    @product = @vendor.products.create(name: 'test_product', c2_test: true, randomize_patients: true, bundle_id: @bundle.id)
  end

  def test_create
    assert_enqueued_jobs 0
    pt = @product.product_tests.build(name: 'test_for_measure_1a', measure_ids: ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'])
    assert pt.valid?, 'product test should be valid with product, name, and measure_id'
  end

  def test_required_fields
    pt = @product.product_tests.build
    assert_equal false,  pt.valid?, 'product test should not be valid without a name'
    assert_equal false,  pt.save, 'should not be able to save product test without a name'
    errors = pt.errors
    assert errors.key?(:name)
    assert errors.key?(:measure_ids)
  end

  def test_status_passing
    measure_id = 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
    vendor = Vendor.create!(name: 'my vendor')
    product = vendor.products.build(name: 'my product', bundle_id: @bundle.id, c1_test: true, c2_test: true,
                                    measure_ids: [measure_id])
    product.save!
    measure_test = product.product_tests.build({ name: "my measure test for measure id #{measure_id}", measure_ids: [measure_id] }, MeasureTest)
    measure_test.save!
    create_test_executions_with_state(measure_test, :passed)
    assert_equal 'passing', measure_test.status

    # measure test should be incomplete if at least one test execution is incomplete
    te = measure_test.tasks[0].test_executions.build(:state => :incomplete)
    te.save!
    assert_equal 'incomplete', measure_test.status

    # measure test should be failing if at least one test execution is failing
    te = measure_test.tasks[1].test_executions.build(:state => :failed)
    te.save!
    assert_equal 'failing', measure_test.status
  end

  def test_repeatability_with_random_seed
    # setup product
    @product.c1_test = true
    @product.c2_test = true
    @product.c3_test = true
    @product.c4_test = true
    @product.randomize_patients = true
    @product.duplicate_patients = true
    @product.allow_duplicate_names = true
    @product.measure_ids = ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE']
    @product.save!

    # create tests with same seed
    seed = Random.new_seed
    test1 = @product.product_tests.build({ :name => 'mtest', :measure_ids => ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                           :bundle_id => @bundle.id, :rand_seed => seed }, MeasureTest)
    test2 = @product.product_tests.build({ :name => 'mtest', :measure_ids => ['BE65090C-EB1F-11E7-8C3F-9A214CF093AE'],
                                           :bundle_id => @bundle.id, :rand_seed => seed }, MeasureTest)
    assert_equal test1.rand_seed, test2.rand_seed, 'random repeatability error: random seeds don\'t match'

    compare_product_tests(test1, test2)

    # create tasks (c1,c2,c3,c4)
    test1.create_tasks
    test2.create_tasks
  end

  # # # # # # # # # # # # # # # # # # # #
  #   H E L P E R   F U N C T I O N S   #
  # # # # # # # # # # # # # # # # # # # #

  def compare_product_tests(test1, test2)
    # compare relevant details
    perform_enqueued_jobs do
      test1.save
      test2.save
      assert_performed_jobs 2

      test1.reload
      test2.reload

      compare_results(test1, test2)

      # compare records
      test1.patients.each_index do |x|
        patient1 = test1.patients.fetch(x)
        patient2 = test2.patients.fetch(x)
        compare_records(patient1, patient2)
      end
    end
  end

  def compare_results(test1, test2)
    # compare expected results
    test1.expected_results.each do |k, _v|
      assert_equal test1.expected_results[k]['IPP'], test2.expected_results[k]['IPP'], 'random repeatability error: IPP results different'
      assert_equal test1.expected_results[k]['DENOM'], test2.expected_results[k]['DENOM'], 'random repeatability error: DENOM results different'
      assert_equal test1.expected_results[k]['NUMER'], test2.expected_results[k]['NUMER'], 'random repeatability error: NUMER results different'
      assert_equal test1.expected_results[k]['DENEX'], test2.expected_results[k]['DENEX'], 'random repeatability error: DENEX results different'
      assert_equal test1.expected_results[k]['DENEXCEP'], test2.expected_results[k]['DENEXCEP'], 'random repeatability error: DENEXCEP results different'
      assert_equal test1.expected_results[k]['MSRPOPL'], test2.expected_results[k]['MSRPOPL'], 'random repeatability error: MSRPOPL results different'
      assert_equal test1.expected_results[k]['MSRPOPLEX'], test2.expected_results[k]['MSRPOPLEX'], 'random repeatability error: MSRPOPLEX results different'
    end
  end

  def compare_records(patient1, patient2)
    # compare names
    assert_equal patient1.first_names, patient2.first_names, 'random repeatability error: given names different'
    assert_equal patient1.familyName, patient2.familyName, 'random repeatability error: family names different'

    # compare dates
    assert_equal patient1.birthDatetime, patient2.birthDatetime, 'random repeatability error: birthdates different'

    # compare extendedData
    # patient1.extendedData.each{|k,v| assert_equal v, patient2[k], 'random repeatability error: extendedData different'}

    # compare all dataElements (expect same order?)
    patient1.dataElements.each_index do |x|
      de1 = patient1.dataElements.fetch(x)
      de2 = patient2.dataElements.fetch(x)
      de1.attributes.each do |k, v|
        assert_nil de2.attributes[k], 'random repeatability error: dataElements different, non-nil match' if v.nil?
        assert_equal v, de2.attributes[k], 'random repeatability error: dataElements different' unless %w[_id id].include?(k)
      end
    end
  end

  def create_test_executions_with_state(product_test, state)
    product_test.tasks.each do |task|
      test_execution = task.test_executions.build(:state => state)
      test_execution.save!
    end
  end
end
