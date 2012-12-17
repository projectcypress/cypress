require 'test_helper'
require 'fileutils'

class QRDATest < ActiveSupport::TestCase

  setup do
    xml_file = File.new(File.join(Rails.root, 'test/fixtures/qrda/QRDA_CATIII_RI_AUG.xml'))
    @doc = Nokogiri::XML(xml_file)
  end


  test "Should get specific results" do
    key1 = { :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540DD"}
    expected1 = {"IPP"=>1000, "DENOM"=>500, "NUMER"=>400, :population_ids=>{ :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540DD"}}
    key2 = {:IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540TT"}
    expected2 = {"IPP"=>1000, "DENOM"=>500, "NUMER"=>400, :population_ids=>{ :IPP=>"D77106C4-8ED0-4C5D-B29E-13DBF255B9FF", :DENOM=>"8B0FA80F-8FFE-494C-958A-191C1BB36DBF", :NUMER=>"9363135E-A816-451F-8022-96CDA7E540TT"}}
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
