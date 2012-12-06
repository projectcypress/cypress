require 'test_helper'
require 'webmock'
class ValuesetUpdaterTest < ActiveSupport::TestCase
include WebMock::API
  setup do
  	Mongoid.default_session['health_data_standards_svs_value_sets'].drop
    collection_fixtures('measures')
		nlm_config = APP_CONFIG["nlm"]
		nlm_config["output_dir"] = nil
		nlm_config["ticket_url"] = "http://localhost/token"
		nlm_config["api_url"]= "http://localhost/vsservice"
  end


	test "Should be able to update valuesets" do 

     stub_request(:post, "http://localhost/token").
            with(:body => {"password"=>"Peanutbutter", "username"=>"Skippy"}).to_return( :body=>"proxy_ticket")



    stub_request(:post, "http://localhost/token/proxy_ticket").to_return( :body=>"ticket")

   oids =  Measure.all.collect{|m| m.oids}.flatten.uniq
   oids.each do |oid|
	   stub_request(:get,"http://localhost/vsservice?id=#{oid}&ticket=ticket").to_return( :body=> 
				%{<RetrieveValueSetResponse xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" cacheExpirationHint="2012-10-23T00:00:00-04:00" xmlns="urn:ihe:iti:svs:2008">
				  <ValueSet ID="#{oid}" version="" displayName="A valueset">
				    <ConceptList>
				    </ConceptList>
				    </ValueSet>
				  </RetrieveValueSetResponse>
			
			})
	 end
    
		count = HealthDataStandards::SVS::ValueSet.count
		assert_equal 0, count, "should be 0 valuesets"

		job = Cypress::ValuesetUpdater.new({:username=>"Skippy", 
                                          :password=>"Peanutbutter",
                                          :clear=>true})
	
    job.perform
		count = HealthDataStandards::SVS::ValueSet.count
		assert_equal oids.length, count, "should be 0 valuesets"

		oids.each do |oid|

			assert HealthDataStandards::SVS::ValueSet.where({:oid=>oid}).first, "Should be a ValueSet with the oid #{oid}"
		end

	end


end