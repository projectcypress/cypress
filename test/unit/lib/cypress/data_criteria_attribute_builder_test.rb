require 'test_helper'

class DataCriteriaAttributeBuilderTest < ActiveSupport::TestCase
  test 'should successfully add attributes to data criteria from a union' do
    measure_package = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'artifacts', 'CMS249v2.zip'), 'application/zip')
    measure_details = { 'episode_of_care' => false }
    loader = Measures::CqlLoader.new(measure_package, measure_details)
    # will return an array of CQMMeasures, most of the time there will only be a single measure
    # if the measure is a composite measure, the array will contain the composite and all of the components
    measure = loader.extract_measures.first
    measure.reporting_program_type = 'ep'

    og_sdc = measure.source_data_criteria.where(codeListId: '2.16.840.1.113883.3.464.1003.199.12.1035').first
    assert_empty og_sdc.dataElementAttributes

    dcab = Cypress::DataCriteriaAttributeBuilder.new
    dcab.build_data_criteria_for_measure(measure)

    new_sdc = measure.source_data_criteria.where(codeListId: '2.16.840.1.113883.3.464.1003.199.12.1035').first
    assert_equal 1, new_sdc.dataElementAttributes.size
    assert_equal 'prevalencePeriod', new_sdc.dataElementAttributes[0].attribute_name
  end

  test 'should successfully add attributes from multiple definitions to data criteria' do
    measure_package = Rack::Test::UploadedFile.new(Rails.root.join('test', 'fixtures', 'artifacts', 'CMS142v8.zip'), 'application/zip')
    measure_details = { 'episode_of_care' => false }
    loader = Measures::CqlLoader.new(measure_package, measure_details)
    # will return an array of CQMMeasures, most of the time there will only be a single measure
    # if the measure is a composite measure, the array will contain the composite and all of the components
    measure = loader.extract_measures.first
    measure.reporting_program_type = 'ep'

    og_sdc = measure.source_data_criteria.where(codeListId: '2.16.840.1.113883.3.526.3.1283').first
    assert_empty og_sdc.dataElementAttributes

    dcab = Cypress::DataCriteriaAttributeBuilder.new
    dcab.build_data_criteria_for_measure(measure)

    new_sdc = measure.source_data_criteria.where(codeListId: '2.16.840.1.113883.3.526.3.1283').first

    assert_equal 1, new_sdc.dataElementAttributes.select { |dea| dea.attribute_name == 'authorDatetime' }.size
    # TODO: Figure out why DCAB is not finding these attributes any more.
    # assert_equal 3, new_sdc.dataElementAttributes.select { |dea| dea.attribute_name == 'sender' }.size
    # assert_equal 3, new_sdc.dataElementAttributes.select { |dea| dea.attribute_name == 'recipient' }.size
    # assert_equal 2, new_sdc.dataElementAttributes.select { |dea| dea.attribute_name == 'negationRationale' }.size
  end
end
