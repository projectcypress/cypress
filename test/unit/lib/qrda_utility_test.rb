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
                {{:code=>"2054-5", :code_system=>"2.16.840.1.113883.6.238"}=>300,
                 {:code=>"2131-1", :code_system=>"2.16.840.1.113883.6.238"}=>350,
                 {:code=>"2028-9", :code_system=>"2.16.840.1.113883.6.238"}=>350},
               QME::QualityReport::ETHNICITY=>
                {{:code=>"2186-5", :code_system=>"2.16.840.1.113883.6.238"}=>350,
                 {:code=>"2135-2", :code_system=>"2.16.840.1.113883.6.238"}=>650},
               QME::QualityReport::SEX=>
                {{:code=>"F", :code_system=>"2.16.840.1.113883.5.1"}=>600,
                 {:code=>"M", :code_system=>"2.16.840.1.113883.5.1"}=>400},
               QME::QualityReport::PAYER=>
                {{:code=>"1", :code_system=>"2.16.840.1.113883.3.221.5"}=>250,
                 {:code=>"2", :code_system=>"2.16.840.1.113883.3.221.5"}=>250}},
             :DENOM=>
              {QME::QualityReport::RACE=>
                {{:code=>"2054-5", :code_system=>"2.16.840.1.113883.6.238"}=>150,
                 {:code=>"2131-1", :code_system=>"2.16.840.1.113883.6.238"}=>175,
                 {:code=>"2028-9", :code_system=>"2.16.840.1.113883.6.238"}=>175},
               QME::QualityReport::ETHNICITY=>
                {{:code=>"2186-5", :code_system=>"2.16.840.1.113883.6.238"}=>175,
                 {:code=>"2135-2", :code_system=>"2.16.840.1.113883.6.238"}=>325},
               QME::QualityReport::SEX=>
                {{:code=>"F", :code_system=>"2.16.840.1.113883.5.1"}=>300,
                 {:code=>"M", :code_system=>"2.16.840.1.113883.5.1"}=>200},
               QME::QualityReport::PAYER=>
                {{:code=>"1", :code_system=>"2.16.840.1.113883.3.221.5"}=>125,
                 {:code=>"2", :code_system=>"2.16.840.1.113883.3.221.5"}=>275}},
             :NUMER=>
              {QME::QualityReport::RACE=>
                {{:code=>"2054-5", :code_system=>"2.16.840.1.113883.6.238"}=>120,
                 {:code=>"2131-1", :code_system=>"2.16.840.1.113883.6.238"}=>140,
                 {:code=>"2028-9", :code_system=>"2.16.840.1.113883.6.238"}=>140},
               QME::QualityReport::ETHNICITY=>
                {{:code=>"2186-5", :code_system=>"2.16.840.1.113883.6.238"}=>140,
                 {:code=>"2135-2", :code_system=>"2.16.840.1.113883.6.238"}=>260},
               QME::QualityReport::SEX=>
                {{:code=>"F", :code_system=>"2.16.840.1.113883.5.1"}=>300,
                 {:code=>"M", :code_system=>"2.16.840.1.113883.5.1"}=>100},
               QME::QualityReport::PAYER=>
                {{:code=>"1", :code_system=>"2.16.840.1.113883.3.221.5"}=>100,
                 {:code=>"2", :code_system=>"2.16.840.1.113883.3.221.5"}=>220}}}, 
                 "IPP"=>1000, "DENOM"=>500, "NUMER"=>400, :population_ids=>{ :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540DD"}}
    key2 = {:IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540TT"}
    expected2 = {:supplemental_data =>{:IPP=>
              {QME::QualityReport::RACE=>
                {{:code=>"2054-5", :code_system=>"2.16.840.1.113883.6.238"}=>300,
                 {:code=>"2131-1", :code_system=>"2.16.840.1.113883.6.238"}=>350,
                 {:code=>"2028-9", :code_system=>"2.16.840.1.113883.6.238"}=>350},
               QME::QualityReport::ETHNICITY=>
                {{:code=>"2186-5", :code_system=>"2.16.840.1.113883.6.238"}=>350,
                 {:code=>"2135-2", :code_system=>"2.16.840.1.113883.6.238"}=>650},
               QME::QualityReport::SEX=>
                {{:code=>"F", :code_system=>"2.16.840.1.113883.5.1"}=>600,
                 {:code=>"M", :code_system=>"2.16.840.1.113883.5.1"}=>400},
               QME::QualityReport::PAYER=>
                {{:code=>"1", :code_system=>"2.16.840.1.113883.3.221.5"}=>250,
                 {:code=>"2", :code_system=>"2.16.840.1.113883.3.221.5"}=>250}},
             :DENOM=>
              {QME::QualityReport::RACE=>
                {{:code=>"2054-5", :code_system=>"2.16.840.1.113883.6.238"}=>150,
                 {:code=>"2131-1", :code_system=>"2.16.840.1.113883.6.238"}=>175,
                 {:code=>"2028-9", :code_system=>"2.16.840.1.113883.6.238"}=>175},
               QME::QualityReport::ETHNICITY=>
                {{:code=>"2186-5", :code_system=>"2.16.840.1.113883.6.238"}=>175,
                 {:code=>"2135-2", :code_system=>"2.16.840.1.113883.6.238"}=>325},
               QME::QualityReport::SEX=>
                {{:code=>"F", :code_system=>"2.16.840.1.113883.5.1"}=>300,
                 {:code=>"M", :code_system=>"2.16.840.1.113883.5.1"}=>200},
               QME::QualityReport::PAYER=>
                {{:code=>"1", :code_system=>"2.16.840.1.113883.3.221.5"}=>125,
                 {:code=>"2", :code_system=>"2.16.840.1.113883.3.221.5"}=>275}},
             :NUMER=>
              {QME::QualityReport::RACE=>
                {{:code=>"2054-5", :code_system=>"2.16.840.1.113883.6.238"}=>120,
                 {:code=>"2131-1", :code_system=>"2.16.840.1.113883.6.238"}=>140,
                 {:code=>"2028-9", :code_system=>"2.16.840.1.113883.6.238"}=>140},
               QME::QualityReport::ETHNICITY=>
                {{:code=>"2186-5", :code_system=>"2.16.840.1.113883.6.238"}=>140,
                 {:code=>"2135-2", :code_system=>"2.16.840.1.113883.6.238"}=>260},
               QME::QualityReport::SEX=>
                {{:code=>"F", :code_system=>"2.16.840.1.113883.5.1"}=>300,
                 {:code=>"M", :code_system=>"2.16.840.1.113883.5.1"}=>100},
               QME::QualityReport::PAYER=>
                {{:code=>"1", :code_system=>"2.16.840.1.113883.3.221.5"}=>100,
                 {:code=>"2", :code_system=>"2.16.840.1.113883.3.221.5"}=>220}}},
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
