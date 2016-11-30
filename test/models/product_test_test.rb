require 'test_helper'

class ProductTestTest < ActiveJob::TestCase
  def setup
    collection_fixtures('patient_cache', 'records', 'bundles', 'measures')
    @vendor = Vendor.create(name: 'test_vendor_name')
    @product = @vendor.products.create(name: 'test_product', c2_test: true, randomize_records: true,
                                       bundle_id: '4fdb62e01d41c820f6000001')
  end

  def test_create
    assert_enqueued_jobs 0
    pt = @product.product_tests.build(name: 'test_for_measure_1a', measure_ids: ['8A4D92B2-397A-48D2-0139-B0DC53B034A7'])
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
    measure_id = '40280381-4BE2-53B3-014C-0F589C1A1C39'
    vendor = Vendor.create!(name: 'my vendor')
    product = vendor.products.build(name: 'my product', bundle_id: '4fdb62e01d41c820f6000001', c1_test: true, c2_test: true,
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

    #setup product
    @product.c1_test = true
    @product.c2_test = true
    @product.c3_test = true
    @product.c4_test = true
    @product.randomize_records = true
    @product.duplicate_records = true
    @product.measure_ids = ['8A4D92B2-397A-48D2-0139-C648B33D5582']
    @product.save!

    #create tests with same seed
    seed = Random.new_seed
    test_1 = @product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-397A-48D2-0139-C648B33D5582'],
                                       bundle_id: '4fdb62e01d41c820f6000001', rand_seed:seed}, MeasureTest)
    test_2 = @product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-397A-48D2-0139-C648B33D5582'],
                                       bundle_id: '4fdb62e01d41c820f6000001', rand_seed:seed}, MeasureTest)

    assert_equal test_1.rand_seed, test_2.rand_seed, 'random repeatability error: random seeds don\'t match'


    #create tasks (c1,c2,c3,c4)
    test_1.create_tasks
    test_2.create_tasks


    #compare relevant details
    perform_enqueued_jobs do

      test_1.save
      test_2.save
      assert_performed_jobs 2

      test_1.reload
      test_2.reload
      
      #compare expected results
      test_1.expected_results.each do |k,v|
        assert_equal test_1.expected_results[k]['IPP'], test_2.expected_results[k]['IPP'], 'random repeatability error: IPP results different'
        assert_equal test_1.expected_results[k]['DENOM'], test_2.expected_results[k]['DENOM'], 'random repeatability error: DENOM results different'
        assert_equal test_1.expected_results[k]['NUMER'], test_2.expected_results[k]['NUMER'], 'random repeatability error: NUMER results different'
        assert_equal test_1.expected_results[k]['DENEX'], test_2.expected_results[k]['DENEX'], 'random repeatability error: DENEX results different'
        assert_equal test_1.expected_results[k]['DENEXCEP'], test_2.expected_results[k]['DENEXCEP'], 'random repeatability error: DENEXCEP results different'
        assert_equal test_1.expected_results[k]['MSRPOPL'], test_2.expected_results[k]['MSRPOPL'], 'random repeatability error: MSRPOPL results different'
        assert_equal test_1.expected_results[k]['MSRPOPLEX'], test_2.expected_results[k]['MSRPOPLEX'], 'random repeatability error: MSRPOPLEX results different'
      end


      #compare records
      byebug
      test_1.records.each_index do |x|
        byebug
        patient_1 = test_1.records.fetch(x)
        patient_2 = test_2.records.fetch(x)

        #compare names
        assert_equal patient_1.first, patient_2.first, 'random repeatability error: first names different'
        assert_equal patient_1.last, patient_2.last, 'random repeatability error: last names different'

        #compare dates
        assert_equal patient_1.birthdate, patient_2.birthdate, 'random repeatability error: birthdates different'
        assert_equal patient_1.deathdate, patient_2.deathdate, 'random repeatability error: deathdates different'
        patient_1.provider_performances.each_index do |y|
          provider_perform_1 = patient_1.provider_performances.fetch(y)
          provider_perform_2 = patient_2.provider_performances.fetch(y)
          assert_equal provider_perform_1.start_date , provider_perform_2.start_date , 'random repeatability error: provider performance start dates different'
          assert_equal provider_perform_1.end_date , provider_perform_2.end_date , 'random repeatability error: provider performance end dates different'
        end
        assert patient_1.compare_sections(patient_2), 'random repeatability error: sections different'

        #compare race, ethnicity, address, insurance
        assert_equal patient_1.race, patient_2.race, 'random repeatability error: races different'
        assert_equal patient_1.ethnicity, patient_2.ethnicity, 'random repeatability error: ethnicities different'
        #assert_equal patient_1.addresses, patient_2.addresses, 'random repeatability error: addresses different' 
        #assert_equal patient_1.insurance_providers, patient_2.insurance_providers, 'random repeatability error: insurance providers different'
        #-> cannot create equality for address and insurance with Faker lib?
      end

    end

  end


  # # # # # # # # # # # # # # # # # # # #
  #   H E L P E R   F U N C T I O N S   #
  # # # # # # # # # # # # # # # # # # # #

  def create_test_executions_with_state(product_test, state)
    product_test.tasks.each do |task|
      test_execution = task.test_executions.build(state: state)
      test_execution.save!
    end
  end
end
