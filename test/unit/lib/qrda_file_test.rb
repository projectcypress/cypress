require 'test_helper'
require 'fileutils'

class QRDATest < ActiveSupport::TestCase

  setup do
    collection_fixtures('measures', '_id', "bundle_id")
    collection_fixtures('bundles', '_id')
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'))
    @doc = Nokogiri::XML(xml_file)
    @m0004 = Measure.where({"hqmf_id" => "8A4D92B2-3946-CDAE-0139-7944ACB700BD"}).first
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

    qrda_file = Validators::QrdaCat3Validator.new(@doc)
    assert_equal expected1, qrda_file.extract_results_by_ids("8a4d92b2-36af-5758-0136-ea8c43244986", key1)
    assert_equal expected2, qrda_file.extract_results_by_ids("8a4d92b2-36af-5758-0136-ea8c43244986", key2)

  end

  test "should be able to tell when a cat I file is good" do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_1/good.xml'))
     doc = Nokogiri::XML(xml_file)
     qrda_file = Validators::QrdaCat1Validator.new([@m0004])
     qrda_file.validate(doc, "filename.xml")
     assert qrda_file.errors.empty? , "Should be 0 errors for good cat 1 file"
  end

  test "should be able to tell when a cat I file is bad do to schema issues" do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_1/bad_schema.xml'))
     doc = Nokogiri::XML(xml_file)
     qrda_file = Validators::QrdaCat1Validator.new([@m0004])

     qrda_file.validate(doc, "filename.xml")
     assert_equal 2, qrda_file.errors.length, "Should report 2 errors, one for the schema issue and one for the schematron issue related to the schema issue"
  end

  test "should be able to tell when a cat I file is bad do to schematron issues" do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_1/bad_schematron.xml'))
     doc = Nokogiri::XML(xml_file)
     qrda_file = Validators::QrdaCat1Validator.new([@m0004])
     qrda_file.validate(doc, "filename.xml")
     assert_equal 1, qrda_file.errors.length, "Should report 1 error"
  end

  test "should be able to tell when a cat I file is bad due to not including expected measures" do
     xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/cat_1/bad_measure_id.xml'))
     doc = Nokogiri::XML(xml_file)
     qrda_file = Validators::QrdaCat1Validator.new([@m0004])
     qrda_file.validate(doc, "filename.xml")
     # New schematron checks for the ID element, and @root and @extension attributes, this adds 2 errors
     # in addition to what's reported by Cypress
     assert_equal 3, qrda_file.errors.length, "Should report 3 errors"
  end


end
