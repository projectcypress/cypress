# frozen_string_literal: true

require 'test_helper'

class HighlightingTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  include ActiveJob::TestHelper

  def setup
    @user = FactoryBot.create(:admin_user)
    @bundle = FactoryBot.create(:executable_bundle)
    @vendor = Vendor.create!(name: 'test_vendor_name')
    @patient = FactoryBot.create(:vendor_test_patient, bundleId: @bundle._id, correlation_id: @vendor.id)
    @patient.calculation_results.destroy_all
  end

  def test_highting_results
    measure = @bundle.measures.first
    effective_date = Time.at(@bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { 'effectiveDate' => effective_date, 'includeClauseResults' => true }
    perform_enqueued_jobs do
      SingleMeasureCalculationJob.perform_now([@patient.id.to_s], measure.id.to_s, @vendor.id.to_s, options)
      ir = IndividualResult.where(correlation_id: @vendor.id.to_s, measure_id: measure.id, patient_id: @patient.id).first
      logic_html = Highlighting.new(measure, ir).render
      document = Nokogiri::HTML(logic_html)
      ir.clause_results.each do |cr|
        next unless %w[TRUE FALSE].include? cr.final

        html_id = "#{cr.statement_name}_#{cr.localId}"
        assert document.at_xpath(".//span[@id='#{html_id}' and @class='clause-true']") if cr.final == 'TRUE'
        assert_nil document.at_xpath(".//span[@id='#{html_id}' and @class='clause-true']") if cr.final == 'FALSE'
      end
    end
  end

  def test_add_highting_results
    measure = @bundle.measures.first
    effective_date = Time.at(@bundle.measure_period_start).in_time_zone.to_formatted_s(:number)
    options = { 'effectiveDate' => effective_date, 'includeClauseResults' => false }
    perform_enqueued_jobs do
      SingleMeasureCalculationJob.perform_now([@patient.id.to_s], measure.id.to_s, @vendor.id.to_s, options)
      ir = IndividualResult.where(correlation_id: @vendor.id.to_s, measure_id: measure.id, patient_id: @patient.id).first
      assert_empty ir.clause_results

      @controller = RecordsController.new
      for_each_logged_in_user([ADMIN]) do
        get :highlighted_results, params: { format: :format_does_not_matter, calculation_result_id: ir.id, id: ir.patient_id }
      end

      ir.reload
      assert ir.clause_results.size.positive?

      logic_html = Highlighting.new(measure, ir).render
      document = Nokogiri::HTML(logic_html)
      ir.clause_results.each do |cr|
        next unless %w[TRUE FALSE].include? cr.final

        html_id = "#{cr.statement_name}_#{cr.localId}"
        assert document.at_xpath(".//span[@id='#{html_id}' and @class='clause-true']") if cr.final == 'TRUE'
        assert_nil document.at_xpath(".//span[@id='#{html_id}' and @class='clause-true']") if cr.final == 'FALSE'
      end
    end
  end
end
