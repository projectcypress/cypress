# frozen_string_literal: true

include TestExecutionsHelper

# # # # # # # #
#   W H E N   #
# # # # # # # #

When(/^the user creates a cvu plus product with records$/) do
  bundle_id = Bundle.default._id
  measure_ids = %w[BE65090C-EB1F-11E7-8C3F-9A214CF093AE 40280382-5FA6-FE85-0160-0918E74D2075]
  @product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                     bundle_id:)

  params = { measure_ids:, 'cvuplus' => 'true' }
  @product.update_with_tests(params)
  @product_test = @product.product_tests.multi_measure_tests.first
  @product_test.generate_patients
  MeasureEvaluationJob.perform_now(@product_test, {})
  wait_for_all_delayed_jobs_to_run
end

When(/^the user creates a cvu plus product$/) do
  bundle_id = Bundle.default._id
  measure_ids = %w[BE65090C-EB1F-11E7-8C3F-9A214CF093AE 40280382-5FA6-FE85-0160-0918E74D2075]
  eh_measure = Measure.where(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE').first
  eh_measure.reporting_program_type = 'eh'
  eh_measure.save
  @product = @vendor.products.create(name: "my product #{rand}", cvuplus: true, randomize_patients: true, duplicate_patients: true,
                                     bundle_id:)

  params = { measure_ids:, 'cvuplus' => 'true' }
  @product.update_with_tests(params)
  @product_test = @product.product_tests.first
end

And(/^the user views multi measure cat3 task$/) do
  task = @product.product_tests.multi_measure_tests.where(reporting_program_type: 'ep').first.tasks.multi_measure_cat3_task
  visit new_task_test_execution_path(task)
end

And(/^the user views a task record$/) do
  find(:xpath, "//a[@href='/records/#{@product_test.patients.first.id}?task_id=#{@product_test.tasks.first.id}']").trigger('click')
end

# # # # # # # #
#   T H E N   #
# # # # # # # #

Then(/^the user should see the download test deck link$/) do
  page.assert_text 'Download Test Deck'
end

#  T H E N #

Then(/^the user should see the list of measures$/) do
  page.assert_text('Measures and Sub Measures')
  page.click_button('Measures and Sub Measures')
  @product_test.measures.each do |measure|
    measure.population_sets_and_stratifications_for_measure.each do |population_set_hash|
      page.assert_text(measure_display_name(measure, population_set_hash))
    end
  end
end

Then(/^the user should see the list expected results$/) do
  page.assert_text('Expected Aggregate Results')
  @product_test.measures.each do |measure|
    measure.population_sets_and_stratifications_for_measure.each do |population_set_hash|
      page.assert_text(measure_display_name(measure, population_set_hash))
    end
  end
end
