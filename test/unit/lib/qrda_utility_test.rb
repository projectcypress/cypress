require 'test_helper'
require 'fileutils'

class QRDATest < ActiveSupport::TestCase

  setup do
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'))
    @doc = Nokogiri::XML(xml_file)
  end

  # test "Should import a QRDA file" do
  #   results = Cypress::QrdaUtility.extract_results(@doc)
  #   expected_results = {{:measure_id=>"8a4d92b2-36af-5758-0136-ea8c43244986", :set_id=>"03876d69-085b-415c-ae9d-9924171040c2", :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :den=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :num=>"9363135E-A816-451F-8022-96CDA7E540DD"}=>{:IPP=>1000, :den=>500, :num=>400, :denex=>20}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :IPP=>"6F906D83-0307-48D1-A1B8-427CE8DC01C7", :strata=>"3B9ADA1B-AFEA-4A9F-BF56-24247FFE0BA5"}=>{:IPP=>1000, :strata=>300}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :IPP=>"6F906D83-0307-48D1-A1B8-427CE8DC01C7", :strata=>"B6A659C9-5F7C-4FBF-9A16-37A5982869DF"}=>{:IPP=>1000, :strata=>350}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :IPP=>"6F906D83-0307-48D1-A1B8-427CE8DC01C7", :strata=>"2C8FF3BE-9E39-4677-AB9B-8B0DCF9DEACC"}=>{:IPP=>1000, :strata=>350}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :IPP=>"6F906D83-0307-48D1-A1B8-427CE8DC01C7", :strata=>"4272A422-2605-46A4-AD5C-CA414CC3D162"}=>{:IPP=>1000, :strata=>150}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :IPP=>"6F906D83-0307-48D1-A1B8-427CE8DC01C7", :strata=>"5BB34B00-FF71-404F-B301-978D71BD4580"}=>{:IPP=>1000, :strata=>150}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :msr_popl=>"1A09812C-D22A-4584-B8A7-DB6D1316D75A", :strata=>"3B9ADA1B-AFEA-4A9F-BF56-24247FFE0BA5", :MEDIAN=>"ecd9156f-370b-40d9-86b6-5c00f0ff9629"}=>{:msr_popl=>500, :strata=>150, :MEDIAN=>55}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :msr_popl=>"1A09812C-D22A-4584-B8A7-DB6D1316D75A", :strata=>"B6A659C9-5F7C-4FBF-9A16-37A5982869DF", :MEDIAN=>"ecd9156f-370b-40d9-86b6-5c00f0ff9629"}=>{:msr_popl=>500, :strata=>150, :MEDIAN=>55}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :msr_popl=>"1A09812C-D22A-4584-B8A7-DB6D1316D75A", :strata=>"2C8FF3BE-9E39-4677-AB9B-8B0DCF9DEACC", :MEDIAN=>"ecd9156f-370b-40d9-86b6-5c00f0ff9629"}=>{:msr_popl=>500, :strata=>200, :MEDIAN=>55}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :msr_popl=>"1A09812C-D22A-4584-B8A7-DB6D1316D75A", :strata=>"4272A422-2605-46A4-AD5C-CA414CC3D162", :MEDIAN=>"ecd9156f-370b-40d9-86b6-5c00f0ff9629"}=>{:msr_popl=>500, :strata=>50,  :MEDIAN=>55}, \
  #                       {:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :msr_popl=>"1A09812C-D22A-4584-B8A7-DB6D1316D75A", :strata=>"5BB34B00-FF71-404F-B301-978D71BD4580", :MEDIAN=>"ecd9156f-370b-40d9-86b6-5c00f0ff9629"}=>{:msr_popl=>500, :strata=>50,  :MEDIAN=>55}} \

  #   expected_results.each do |key, expected_value|
  #     assert_equal results[key], expected_value
  #   end
   
  # end

  test "Should get specific results" do
    key1 = { :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540DD"}
    expected1 = {{ :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540DD"}=>{:IPP=>1000, :DENOM=>500, :NUMER=>400}}
    key2 = {:IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540TT"}
    expected2 = {{ :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540TT"}=>{:IPP=>1000, :DENOM=>500, :NUMER=>400}}
    # key3 = key1 + key2
    # expected3 = expected1.merge(expected2)
    # key4 = [{:measure_id=>"8a4d92b2-37d1-f95b-0137-dd4b0eb62de6", :set_id=>"3fd13096-2c8f-40b5-9297-b714e8de9133", :msr_popl=>"INVALID", :strata=>"INVALID", :denex=>"INVALID"}]
    # expected4 = {}

    assert_equal expected1, Cypress::QrdaUtility.extract_results_by_ids(@doc, "8a4d92b2-36af-5758-0136-ea8c43244986", key1)
    assert_equal expected2, Cypress::QrdaUtility.extract_results_by_ids(@doc, "8a4d92b2-36af-5758-0136-ea8c43244986", key2)
    # assert_equal expected3, Cypress::QrdaUtility.extract_results_by_ids(@doc, key3)
    # assert_equal expected4, Cypress::QrdaUtility.extract_results_by_ids(@doc, key4)
  end

  
  # test "should validate QRDA " do
  #   xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2010_1.xml'))
  #   doc = Nokogiri::XML(xml_file)
  #   errors = Cypress::PqriUtility.validate(doc)
  #   assert errors.size , 0,  "Should be 0 errors but there were #{errors}"
    
  # end
  
end
