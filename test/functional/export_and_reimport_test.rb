require 'test_helper'
require 'create_download_zip'


class ExportAndReimportTest < ActionController::TestCase
  
  setup do
    puts "wiping db"
    wipe_db_and_load_patients()
    puts "loading measures"
    load_measures()
    collection_fixtures('vendors', '_id',"user_ids")
    collection_fixtures('products','_id','vendor_id')
    collection_fixtures('users',"_id", "vendor_ids")
    collection_fixtures('product_tests', '_id','product_id',"user_id")
  end
  
  test "Export records, reimport them, then compare results" do

    assert Record.count  == 225 , "Wrong number of records in DB before export"
    assert Measure.count == 78  , "Wrong number of measures in DB"
    ptest = ProductTest.find('4f58f8de1d41c851eb000478')
    ptest.effective_date =  Time.gm(APP_CONFIG["effective_date"]["year"],
                                    APP_CONFIG["effective_date"]["month"],
                                    APP_CONFIG["effective_date"]["day"]).to_i
    puts "creating zip"                                
    zip = Cypress::CreateDownloadZip.create_zip(Record.where("test_id" => nil),'c32')

    puts "importing records"
    pij = Cypress::PatientImportJob.new(UUID.generate,
      'zip_file_location' => zip.path,
      'test_id' => ptest.id,
      'format' => 'c32')
    pij.perform
   

    assert Record.count  == 450 , "Wrong number of records in DB after reimport"

   puts "Evaling measures"
    Measure.installed.each do |measure|
      Cypress::MeasureEvaluator.eval_for_static_records(measure,false)
      Cypress::MeasureEvaluator.eval(ptest,measure,false)
    end
    puts "querying records"
    # there will be only 2 sets of values inthe query cache, the initail patients and those of the test so we can 
    # group the results by measure_id and sub_id then check that all items in the group match
    results =  Mongoid.master["query_cache"].group({key:[:measure_id, :sub_id],initial:{values:[]},reduce:"function(doc,out){out.values[out.values.length] = doc;}"})
    assert_equal results.length, 78
    correct = true
    results.each do |res|
      if res.values.length != 2
        correct == false
        next
      end
      r1 = values[0]
      r2 = values[1]
      
      if r1["population"]  !=  r2["population"]  || r1["denominator"] != 	r2["denominator"] ||
    			r1["numerator"]   != 	r2["numerator"]   || r1["exclusions"]  != 	r2["exclusions"]  then
		     puts "#{r1.inspect }     #{r2.inspect}"
		     correct = false
      end                   
    end
    
    assert correct , "Inconsistent results found"
  end
end
