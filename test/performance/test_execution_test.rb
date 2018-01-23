require 'test_helper'
require 'rails/performance_test_help'

class TestExecutionPerfTest < ActionDispatch::PerformanceTest
  self.profile_options = { runs: 1, metrics: [:wall_time, :process_time] }
  # Refer to the documentation for all available options
  # self.profile_options = { runs: 5, metrics: [:wall_time, :memory],
  #                          output: 'tmp/performance', formats: [:flat] }

  def setup
    collection_fixtures('product_tests', 'products', 'bundles',
                        'measures', 'records', 'patient_cache',
                        'health_data_standards_svs_value_sets')
    @product_test = ProductTest.find('51703a6a3054cf8439000044')
    @task = C2Task.new
    @task.product_test = @product_test
    @file = File.new(File.join(Rails.root, 'test/fixtures/qrda/ep_test_qrda_cat3_good.xml')).read
  end

  def test_expected_results_validator
    validator = ::Validators::ExpectedResultsValidator.new(@product_test.expected_results)
    validator.validate(@file, 'task' => @task)
  end

  # def test_measure_period_validator
  #   validator = ::Validators::MeasurePeriodValidator.new
  #   validator.validate(@file, 'task' => @task)
  # end

  # def setup
  #   subfolder = 'validator_perftest'
  #   collection_fixtures('products/' + subfolder, 'product_tests/' + subfolder)
  #   BundleUploadJob.perform_now('test/fixtures/bundles/2017.0.0.3beta.zip', '2017.0.0.3beta.zip')
  #   @ptest = ProductTest.find('59652218e5f131326284c77c')
  #   @ptest.product.bundle = Bundle.all.first
  #   @task = @ptest.tasks.create({})
  #   @te = @task.test_executions.create({})
  #   @artifact = Artifact.new(file: create_rack_test_file('test/fixtures/artifacts/CMS71v7.zip', 'application/zip'))
  #   @options = { 'test_execution' => @te, 'task' => @task }
  # end
  #
  # def test_measure_period_validator
  #   @te.validate_artifact([::Validators::MeasurePeriodValidator.new()], @artifact, @options)
  # end
  #
  # def test_calculating_smoking_gun_validator
  #   @te.validate_artifact([::Validators::CalculatingSmokingGunValidator.new(@ptest.measures, @ptest.records, @ptest.id)], @artifact, @options)
  # end
end
