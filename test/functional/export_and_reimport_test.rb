require 'test_helper'
require 'create_download_zip'

class ExportAndReimportTest < ActionController::TestCase
  
  setup do
    if !ENV['MEASURE_DIR']
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      puts "Cannot run Export and Reimport test, missing environment variable MEASURE_DIR"
      puts "Set MEASURE_DIR to the directory where the Measures project resides"
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      return
    end
    ENV['MEASURE_PROPS'] = ENV['MEASURE_PROPS'] || ENV['MEASURE_DIR'] + '/measure_props'
    wipe_db_and_load_patients()
    loader = QME::Database::Loader.new('cypress_test')
    loader.save_bundle(ENV['MEASURE_DIR'],'measures')
    collection_fixtures('product_tests', '_id')
  end
  
  test "Export records, reimport them, then compare results" do
    if !ENV['MEASURE_PROPS']
      assert true
      return
    end
    assert Record.count  == 225 , "Wrong number of records in DB before export"
    assert Measure.count == 78  , "Wrong number of measures in DB"
    ptest = ProductTest.find('4f58f8de1d41c851eb000478')
    ptest.effective_date =  Time.gm(APP_CONFIG["effective_date"]["year"],
                                    APP_CONFIG["effective_date"]["month"],
                                    APP_CONFIG["effective_date"]["day"]).to_i
    zip = Cypress::CreateDownloadZip.create_zip(Record.where("test_id" => nil),'c32')

    pij = Cypress::PatientImportJob.new(UUID.generate,
      'zip_file_location' => zip.path,
      'test_id' => ptest.id,
      'format' => 'c32')
    pij.perform
    zip.close

    assert Record.count  == 450 , "Wrong number of records in DB after reimport"

    static_results  = []
    imported_results = []
    Measure.installed.each do |measure|
      result = Cypress::MeasureEvaluator.eval_for_static_records(measure,false)
      static_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["numerator"]:'   + result['numerator'].to_s + "\n")
      static_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["denominator"]:' + result['denominator'].to_s + "\n")
      static_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["exclusions"]:'  + result['exclusions'].to_s + "\n")

      result = Cypress::MeasureEvaluator.eval(ptest,measure,false)
      imported_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["numerator"]:'   + result['numerator'].to_s + "\n")
      imported_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["denominator"]:' + result['denominator'].to_s + "\n")
      imported_results.push(measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["exclusions"]:'  + result['exclusions'].to_s + "\n")
    end

    assert static_results.count == imported_results.count

    correct = true
    static_results.zip(imported_results).each do |static,imported|
      if static != imported
        puts "Static records Result:   " + static
        puts "Imported records Result: "+ imported
        correct = false
      end
    end
    assert correct , "Inconsistent results found"
  end
end
