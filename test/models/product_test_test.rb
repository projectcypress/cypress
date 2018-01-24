require 'test_helper'

class ProductTestTest < ActiveJob::TestCase
  def setup
    @vendor = FactoryGirl.create(:vendor)
    @bundle = FactoryGirl.create(:static_bundle)
    @product = @vendor.products.create(name: 'test_product', c2_test: true, randomize_records: true, bundle_id: @bundle.id)
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
    @product.randomize_records = true
    @product.duplicate_records = true
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
      test1.records.each_index do |x|
        patient1 = test1.records.fetch(x)
        patient2 = test2.records.fetch(x)
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
    assert_equal patient1.first, patient2.first, 'random repeatability error: first names different'
    assert_equal patient1.last, patient2.last, 'random repeatability error: last names different'

    # compare dates
    assert_equal patient1.birthdate, patient2.birthdate, 'random repeatability error: birthdates different'
    assert_equal patient1.deathdate, patient2.deathdate, 'random repeatability error: deathdates different'
    patient1.provider_performances.each_index do |y|
      provider_perform1 = patient1.provider_performances.fetch(y)
      provider_perform2 = patient2.provider_performances.fetch(y)
      assert_equal provider_perform1.start_date, provider_perform2.start_date, 'random repeatability error: provider performance start dates different'
      assert_equal provider_perform1.end_date, provider_perform2.end_date, 'random repeatability error: provider performance end dates different'
    end

    # assert patient1.compare_sections(patient2), 'random repeatability error: sections different'
    # compare patient sections
    sections = %i[allergies care_goals conditions encounters immunizations medical_equipment
                  medications procedures results communications family_history social_history vital_signs support advance_directives
                  functional_statuses] # skip insurance provider section
    sections.each do |sec|
      assert_equal (patient1.send sec), (patient2.send sec), 'error'
    end

    # compare race, ethnicity, address, insurance
    assert_equal patient1.race, patient2.race, 'random repeatability error: races different'
    assert_equal patient1.ethnicity, patient2.ethnicity, 'random repeatability error: ethnicities different'
    # assert_equal patient1.addresses, patient2.addresses, 'random repeatability error: addresses different'
    # assert_equal patient1.insurance_providers, patient2.insurance_providers, 'random repeatability error: insurance providers different'
    #-> cannot create equality for address and insurance with Faker lib?
  end

  def create_test_executions_with_state(product_test, state)
    product_test.tasks.each do |task|
      test_execution = task.test_executions.build(:state => state)
      test_execution.save!
    end
  end
end
