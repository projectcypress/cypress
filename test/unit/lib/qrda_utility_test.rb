require 'test_helper'
require 'fileutils'

class QRDATest < ActiveSupport::TestCase

  setup do
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'))
    @doc = Nokogiri::XML(xml_file)
  end


  test "Should get specific results" do
    key1 = { :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540DD"}
    expected1 = { :supplemental_data =>{:IPP=>
              {QME::QualityReport::RACE=>
                {"2054-5"=>300,
                 "2131-1"=>350,
                 "2028-9"=>350},
               QME::QualityReport::ETHNICITY=>
                {"2186-5"=>350,
                 "2135-2"=>650},
               QME::QualityReport::SEX=>
                {"F"=>600,
                 "M"=>400},
               QME::QualityReport::PAYER=>
                {"1"=>250,
                 "2"=>250}},
             :DENOM=>
              {QME::QualityReport::RACE=>
                {"2054-5"=>150,
                 "2131-1"=>175,
                 "2028-9"=>175},
               QME::QualityReport::ETHNICITY=>
                {"2186-5"=>175,
                 "2135-2"=>325},
               QME::QualityReport::SEX=>
                {"F"=>300,
                 "M"=>200},
               QME::QualityReport::PAYER=>
                {"1"=>125,
                 "2"=>275}},
             :NUMER=>
              {QME::QualityReport::RACE=>
                {"2054-5"=>120,
                 "2131-1"=>140,
                 "2028-9"=>140},
               QME::QualityReport::ETHNICITY=>
                {"2186-5"=>140,
                 "2135-2"=>260},
               QME::QualityReport::SEX=>
                {"F"=>300,
                 "M"=>100},
               QME::QualityReport::PAYER=>
                {"1"=>100,
                 "2"=>220}}}, 
                 "IPP"=>1000, "DENOM"=>500, "NUMER"=>400, :population_ids=>{ :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540DD"}}
    key2 = {:IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540TT"}
    expected2 = {:supplemental_data =>{:IPP=>
              {QME::QualityReport::RACE=>
                {"2054-5"=>300,
                 "2131-1"=>350,
                 "2028-9"=>350},
               QME::QualityReport::ETHNICITY=>
                {"2186-5"=>350,
                 "2135-2"=>650},
               QME::QualityReport::SEX=>
                {"F"=>600,
                 "M"=>400},
               QME::QualityReport::PAYER=>
                {"1"=>250,
                 "2"=>250}},
             :DENOM=>
              {QME::QualityReport::RACE=>
                {"2054-5"=>150,
                 "2131-1"=>175,
                 "2028-9"=>175},
               QME::QualityReport::ETHNICITY=>
                {"2186-5"=>175,
                 "2135-2"=>325},
               QME::QualityReport::SEX=>
                {"F"=>300,
                 "M"=>200},
               QME::QualityReport::PAYER=>
                {"1"=>125,
                 "2"=>275}},
             :NUMER=>
              {QME::QualityReport::RACE=>
                {"2054-5"=>120,
                 "2131-1"=>140,
                 "2028-9"=>140},
               QME::QualityReport::ETHNICITY=>
                {"2186-5"=>140,
                 "2135-2"=>260},
               QME::QualityReport::SEX=>
                {"F"=>300,
                 "M"=>100},
               QME::QualityReport::PAYER=>
                {"1"=>100,
                 "2"=>220}}},
                  "IPP"=>1000, "DENOM"=>500, "NUMER"=>400, :population_ids=>{ :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540TT"}}

    assert_equal expected1, Cypress::QrdaUtility.extract_results_by_ids(@doc, "8a4d92b2-36af-5758-0136-ea8c43244986", key1)
    assert_equal expected2, Cypress::QrdaUtility.extract_results_by_ids(@doc, "8a4d92b2-36af-5758-0136-ea8c43244986", key2)

  end

  
  # test "should validate QRDA " do
  #   xml_file = File.new(File.join(Rails.root, 'test/fixtures/pqri/pqri_2010_1.xml'))
  #   doc = Nokogiri::XML(xml_file)
  #   errors = Cypress::PqriUtility.validate(doc)
  #   assert errors.size , 0,  "Should be 0 errors but there were #{errors}"
    
  # end
  
end
