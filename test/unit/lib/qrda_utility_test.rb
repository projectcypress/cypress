require 'test_helper'
require 'fileutils'

class QRDATest < ActiveSupport::TestCase

 
  test "Should import a QRDA file" do
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'))
    doc = Nokogiri::XML(xml_file)
    results = Cypress::QrdaUtility.extract_results(doc)
    measure1 = results['0436']
    measure2 = results['0496']

    numerator = measure1['numerator'][0]
    denominator = measure1['denominator'][0]
    den_exclusions = measure1['denominator_exclusions'][0]
    initial_population = measure1['initial_population'][0]

    assert_equal measure1['performance_rate']['value'], 0.833
    assert_equal measure1['performance_rate']['expected'], 0.625
    assert_equal measure1['reporting_rate']['value'], 0.84

    assert_equal numerator['value'] , 400
    assert_equal numerator['expected_value'] , 300
    assert_equal numerator['race']['2054-5']['value'] , 120
    assert_equal numerator['race']['2131-1']['value'] , 140
    assert_equal numerator['race']['2028-9']['value'] , 140
    assert_equal numerator['ethnicity']['2186-5']['value'] , 140
    assert_equal numerator['ethnicity']['2135-2']['value'] , 260
    assert_equal numerator['gender']['F']['value'] , 300
    assert_equal numerator['gender']['M']['value'] , 100

    assert_equal denominator['value'] , 500
    assert_equal denominator['race']['2054-5']['value'] , 150
    assert_equal denominator['race']['2131-1']['value'] , 175
    assert_equal denominator['race']['2028-9']['value'] , 175
    assert_equal denominator['ethnicity']['2186-5']['value'] , 175
    assert_equal denominator['ethnicity']['2135-2']['value'] , 325
    assert_equal denominator['gender']['F']['value'] , 300
    assert_equal denominator['gender']['M']['value'] , 200

    assert_equal initial_population['value'] , 1000
    assert_equal initial_population['race']['2054-5']['value'] , 300
    assert_equal initial_population['race']['2131-1']['value'] , 350
    assert_equal initial_population['race']['2028-9']['value'] , 350
    assert_equal initial_population['ethnicity']['2186-5']['value'] , 350
    assert_equal initial_population['ethnicity']['2135-2']['value'] , 650
    assert_equal initial_population['gender']['F']['value'] , 600
    assert_equal initial_population['gender']['M']['value'] , 400

    assert_equal den_exclusions['value'] , 20
    assert_equal den_exclusions['race']['2054-5']['value'] , 6
    assert_equal den_exclusions['race']['2131-1']['value'] , 7
    assert_equal den_exclusions['race']['2028-9']['value'] , 7
    assert_equal den_exclusions['ethnicity']['2186-5']['value'] , 7
    assert_equal den_exclusions['ethnicity']['2135-2']['value'] , 13
    assert_equal den_exclusions['gender']['F']['value'] , 12
    assert_equal den_exclusions['gender']['M']['value'] , 8

    assert_equal measure1['measure_population'] , ''
    assert_equal measure1['numerator_exclusions'] , ''
    assert_equal measure1['denominator_exceptions'] , ''

    #measure 2
    measure_population = measure2['measure_population'][0]
    initial_population = measure2['initial_population'][0]

    assert_equal measure2['measure_population'][0]['value'] , 500
    assert_equal measure2['initial_population'][0]['value'] , 1000

    assert_equal initial_population['value'] , 1000
    assert_equal initial_population['race']['2054-5']['value'] , 300
    assert_equal initial_population['race']['2131-1']['value'] , 350
    assert_equal initial_population['race']['2028-9']['value'] , 350
    assert_equal initial_population['ethnicity']['2186-5']['value'] , 350
    assert_equal initial_population['ethnicity']['2135-2']['value'] , 650
    assert_equal initial_population['gender']['F']['value'] , 600
    assert_equal initial_population['gender']['M']['value'] , 400
    assert_equal initial_population['stratum'][0]['value'] , 300
    assert_equal initial_population['stratum'][0]['reference'] , "3B9ADA1B-AFEA-4A9F-BF56-24247FFE0BA5"
    assert_equal initial_population['stratum'][1]['value'] , 350
    assert_equal initial_population['stratum'][1]['reference'] , "B6A659C9-5F7C-4FBF-9A16-37A5982869DF"
    assert_equal initial_population['stratum'][2]['value'] , 350
    assert_equal initial_population['stratum'][2]['reference'] , "2C8FF3BE-9E39-4677-AB9B-8B0DCF9DEACC"
    assert_equal initial_population['stratum'][3]['value'] , 150
    assert_equal initial_population['stratum'][3]['reference'] , "4272A422-2605-46A4-AD5C-CA414CC3D162"
    assert_equal initial_population['stratum'][4]['value'] , 150
    assert_equal initial_population['stratum'][4]['reference'] , "5BB34B00-FF71-404F-B301-978D71BD4580"

    assert_equal measure_population['value'] , 500
    assert_equal measure_population['race']['2054-5']['value'] , 300
    assert_equal measure_population['race']['2131-1']['value'] , 100
    assert_equal measure_population['race']['2028-9']['value'] , 100
    assert_equal measure_population['ethnicity']['2186-5']['value'] , 350
    assert_equal measure_population['ethnicity']['2135-2']['value'] , 150
    assert_equal measure_population['gender']['F']['value'] , 300
    assert_equal measure_population['gender']['M']['value'] , 200
    assert_equal measure_population['stratum'][0]['value'] , 150
    assert_equal measure_population['stratum'][0]['reference'] , "3B9ADA1B-AFEA-4A9F-BF56-24247FFE0BA5"
    assert_equal measure_population['stratum'][1]['value'] , 150
    assert_equal measure_population['stratum'][1]['reference'] , "B6A659C9-5F7C-4FBF-9A16-37A5982869DF"
    assert_equal measure_population['stratum'][2]['value'] , 200
    assert_equal measure_population['stratum'][2]['reference'] , "2C8FF3BE-9E39-4677-AB9B-8B0DCF9DEACC"
    assert_equal measure_population['stratum'][3]['value'] , 50
    assert_equal measure_population['stratum'][3]['reference'] , "4272A422-2605-46A4-AD5C-CA414CC3D162"
    assert_equal measure_population['stratum'][4]['value'] , 50
    assert_equal measure_population['stratum'][4]['reference'] , "5BB34B00-FF71-404F-B301-978D71BD4580"
    assert_equal measure_population['continuous_values'][0]['reference'] , "ecd9156f-370b-40d9-86b6-5c00f0ff9629"
    assert_equal measure_population['continuous_values'][0]['code'] , "MEDIAN"
    assert_equal measure_population['continuous_values'][0]['unit'] , "min"
    assert_equal measure_population['continuous_values'][0]['value'] , 55
    assert_equal measure_population['continuous_values'][0]['expected'] , 60

    assert_equal measure2['numerator'] , ''
    assert_equal measure2['numerator_exclusions'] , ''
    assert_equal measure2['denominator'] , ''
    assert_equal measure2['denominator_exclusions'] , ''
    assert_equal measure2['denominator_exceptions'] , ''

  end


  
  # test "should validate QRDA " do
  #   xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2010_1.xml'))
  #   doc = Nokogiri::XML(xml_file)
  #   errors = Cypress::PqriUtility.validate(doc)
  #   assert errors.size , 0,  "Should be 0 errors but there were #{errors}"
    
  # end
  
end
