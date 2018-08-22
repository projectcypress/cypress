include RecordsHelper
include ApplicationHelper

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

And(/^the user should see a way to switch bundles$/) do
  assert Bundle.count > 1
  page.assert_text 'Annual Update Bundle'
  Bundle.all.each do |bundle|
    assert page.find_field(bundle.title), "bundle #{bundle.title} not found on page"
  end
end

And(/^the user should not see a way to switch bundles$/) do
  page.assert_text 'Annual Update Bundle'
  assert_raise Capybara::ElementNotFound do
    page.find_field(@bundle.title)
  end
  page.assert_text @bundle.title
end

And(/^the user searches for a measure$/) do
  page.fill_in 'search_measures', with: @measure.display_name
end

And(/^the user selects a measure from the dropdown$/) do
  page.execute_script "$('#search_measures').trigger('focus')"
  page.execute_script "$('#search_measures').trigger('keydown')"
  assert page.has_selector?('.ui-autocomplete .list-group-item'), 'no dropdown result'

  page.find('.ui-autocomplete .list-group-item').click
end

Then(/^the user should see results for that measure$/) do
  page.assert_text @measure.display_name + ' Patients'

  records = records_by_measure(@bundle.patients, @measure)

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
  page.assert_text "Patient Information for #{@patient.first_names} #{@patient.familyName}"
  page.assert_text full_gender_name(@patient.gender)
  SECTIONS.each do |section|
    page.assert_text section.titleize

    next unless @patient[section]
    @patient[section].each do |data_criteria|
      page.assert_text data_criteria['description']
    end
  end
  @measures = @bundle.measures.where(:_id.in => @patient.calculation_results.map(&:measure_id))
  @measures.each do |m|
    page.assert_text m.display_name
  end
end

When(/^the user clicks a Download button$/) do
  # Only worry about the first download link since we can't check much with the response anyway
  page.all('.download-btn').first.click_link 'Download'
end

Then(/^a zip file should be downloaded$/) do
  assert_match(/attachment; filename=\".*\.zip\"/, page.response_headers['Content-Disposition'])
end

Then(/^the user should not see deprecated bundles$/) do
  page.assert_no_text '(Deprecated)'
end
