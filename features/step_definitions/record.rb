# frozen_string_literal: true

include RecordsHelper
include ApplicationHelper

Given(/^a vendor patient has measure_calculations$/) do
  Bundle.destroy_all
  @bundle = FactoryBot.create(:executable_bundle)
  @vendor = Vendor.create!(name: 'test_vendor_name')
  @patient = FactoryBot.create(:vendor_test_patient, bundleId: @bundle._id, correlation_id: @vendor.id)
  @patient.calculation_results.destroy_all
  measure = @bundle.measures.find_by(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE')
  second_measure = measure.clone
  second_measure.hqmf_id = 'CE65090C-EB1F-11E7-8C3F-9A214CF093AE'
  second_measure.cms_id = 'CMS032v7'
  second_measure.save
  effective_date = Time.at(@bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
  options = { 'effectiveDate' => effective_date, 'includeClauseResults' => true }
  SingleMeasureCalculationJob.perform_now([@patient.id.to_s], measure.id.to_s, @vendor.id.to_s, options)
  SingleMeasureCalculationJob.perform_now([@patient.id.to_s], second_measure.id.to_s, @vendor.id.to_s, options)
  second_measure.source_data_criteria = nil
  wait_for_all_delayed_jobs_to_run
end

When(/^the user visits the records page$/) do
  visit '/records/'
  @bundle = Bundle.default
  @other_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample
  @measure = @bundle.measures.find_by(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE') unless @bundle.measures.count.eql? 0
end

And(/^there is only 1 bundle installed$/) do
  Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).destroy_all
  assert Bundle.count == 1
  visit '/records/' # force reload the page
end

And(/^the Master Patient List zip is not already built$/) do
  Bundle.all.each do |bundle|
    FileUtils.rm_rf(bundle.mpl_path)
  end
  visit '/records/' # force reload the page
end

Then(/^the user should see (.*) for all MPL downloads$/) do |download_text|
  page.assert_text 'Annual Update Bundle'
  mpl_download_div = page.all('.download-btn')
  mpl_download_div.each do |mpl_download|
    assert mpl_download.has_text?(download_text)
  end
end

Then(/^the user should see a list of patients$/) do
  page.assert_text 'All Patients'
  assert page.has_selector?('table tbody tr', count: @bundle.patients.length), 'different count'
end

And(/^the user should see a way to filter patients$/) do
  page.assert_text 'Type to search by measure'
  assert page.has_selector?('#search_measures'), 'no search box'
end

And(/^the user should see a way to select all patients$/) do
  page.assert_text 'Select All'
  assert page.has_selector?('#vendor-patient-select-all'), 'no select button'
end

And(/^the user should see a way to switch bundles$/) do
  assert Bundle.count > 1
  page.assert_text 'Annual Update Bundle'
  Bundle.all.each do |bundle|
    assert page.find_field(bundle.title), "bundle #{bundle.title} not found on page"
  end
end

And(/^the user should see a way to analyize patients$/) do
  page.assert_text 'View Patient Analytics'
end

And(/^the user views patient analytics$/) do
  page.click_link 'View Patient Analytics'
end

And(/^the user should see patient analytics$/) do
  page.assert_text 'Analysis of Patients'
end

And(/^the user searches for a measure$/) do
  page.fill_in 'search_measures', with: @measure.title
end

And(/^the user selects a measure from the dropdown$/) do
  page.execute_script "$('#search_measures').trigger('focus')"
  page.execute_script "$('#search_measures').trigger('keydown')"
  assert page.has_selector?('.ui-autocomplete .list-group-item'), 'no dropdown result'

  page.find('.ui-autocomplete .list-group-item', match: :first).click
end

Then(/^the user should see results for that measure$/) do
  page.assert_text "#{measure_display_name(@measure, @measure.population_sets_and_stratifications_for_measure.first)} Patients"
  patients = @vendor ? @vendor.patients.where(bundleId: @bundle.id.to_s) : @bundle.patients
  records = records_by_measure(patients, @measure, nil, @vendor, @measure.population_sets_and_stratifications_for_measure.first.population_set_id)

  assert page.has_selector?('table tbody tr', count: records.length), 'different number'
  assert page.has_selector?('.result-marker'), 'no result marker'
end

And(/^the user selects a bundle$/) do
  page.choose @other_bundle.title
end

Then(/^the user should see records for that bundle$/) do
  assert page.has_selector?('table tbody tr', count: @other_bundle.patients.length), 'different number'
end

When(/^the Master Patient List zip is ready for download$/) do
  wait_for_all_delayed_jobs_to_run
end

Then(/^the user should see a Download button$/) do
  mpl_download_div = page.all('.download-btn')
  mpl_download_div.each do |mpl_download|
    mpl_download.find('.btn').has_text? 'Download'
  end
end

When(/^the user visits a record$/) do
  @bundle = Bundle.default
  @patient = @bundle.patients.first
  visit "/records/#{@patient.id}"
end

Then(/^the user sees details$/) do
  page.assert_text "Patient Test Record: #{@patient.first_names} #{@patient.familyName}"
  page.assert_text @patient.gender
  @measures = @bundle.measures.where(:_id.in => @patient.calculation_results.map(&:measure_id))
  sf_patient = @patient.clone
  Cypress::ScoopAndFilter.new(@measures).scoop_and_filter(sf_patient)
  sf_patient.qdmPatient.dataElements.each do |data_criteria|
    page.assert_text data_criteria['description']
  end
  page.assert_text @patient.id.to_s
  @measures.each do |m|
    page.assert_text m.description
  end
end

When(/^the user clicks a Download button$/) do
  # Only worry about the first download link since we can't check much with the response anyway
  page.all('.download-btn').first.click_link 'Download'
end

Then('a zip file should be downloaded within {int} seconds') do |int|
  # expect(page.response_headers['Content-Disposition']).to be("attachment; filename=\".*\.zip\"")
  Timeout.timeout(int) do
    sleep 0.1 until page.response_headers['Content-Disposition']
  end
  assert_match(/attachment; filename=".*\.zip"/, page.response_headers['Content-Disposition'])
end

Then(/^the user should not see deprecated bundles$/) do
  page.assert_no_text '(Deprecated)'
end

When(/^the user visits the vendor records page$/) do
  @bundle = FactoryBot.create(:executable_bundle)
  @other_bundle = Bundle.where('$or' => [{ 'active' => false }, { :active.exists => false }]).sample
  @vendor = Vendor.create!(name: 'test_vendor_name')
  @measure = @bundle.measures.find_by(hqmf_id: 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE') unless @bundle.measures.count.eql? 0
  @patient = FactoryBot.create(:vendor_test_patient, bundleId: @bundle._id, correlation_id: @vendor.id)
  PatientAnalysisJob.perform_now(@bundle.id.to_s, @vendor.id.to_s)
  wait_for_all_delayed_jobs_to_run
  visit "/records?vendor_id=#{@vendor.id}&bundle_id=#{@bundle.id}"
end

Then(/^the user should see a list of vendor patients$/) do
  page.assert_text 'All Patients'
  patients = @vendor.patients.where(bundleId: @bundle.id.to_s)
  assert page.has_selector?('table tbody tr', count: patients.length), 'different count'
end

When(/^the user visits the vendor patient link$/) do
  visit "/vendors/#{@vendor.id}/records/#{@patient.id}"
end

Then(/^the user should see vendor patient details$/) do
  page.assert_text "Patient Test Record: #{@patient.first_names} #{@patient.familyName}"
  page.assert_text @patient.gender
  page.assert_text 'View Logic Highlighting'
  page.first('button', text: 'View Logic Highlighting').click
  assert page.first(:xpath, './/span[@id="ED Visit_24" and @class="clause-true"]'), 'clause should highlighted as true'
  @measures = @bundle.measures.where(:_id.in => @patient.calculation_results.map(&:measure_id))
  sf_patient = @patient.clone
  Cypress::ScoopAndFilter.new(@measures).scoop_and_filter(sf_patient)
  sf_patient.qdmPatient.dataElements.each do |data_criteria|
    page.assert_text data_criteria['description']
  end
  @measures.each do |m|
    page.assert_text m.cms_id
  end
end

When(/^the user filters on (.*)$/) do |cms_id|
  page.has_content?('button')
  page.first('button', text: 'Select Measure(s)').click
  find(:xpath, "//a[text() = '#{cms_id}']").click
end

Then(/^the user should see text (.*)$/) do |data_criteria|
  page.assert_text data_criteria
end

Then(/^the user should not see text (.*)$/) do |data_criteria|
  page.assert_no_text data_criteria
end
