require 'test_helper'
require 'patient_importer'

class PatientImporterTest < ActiveSupport::TestCase
  def test_patient_import
    # Collect the db and file that we need to import
    db = Mongoid.master
    mpl_file = File.new(File.join(Rails.root, "db", "mpl", "bundle_#{APP_CONFIG["mpl_version"]}.zip"))
    
    # Delete all Records and bundles so we're positive we're importing into empty collections
    Record.destroy_all
    db.collection("bundles").drop    
    assert_equal 0, Record.all.size
    assert_equal 0, db.collection("bundles").size
    
    # Import the patients and check to see that the 225 Records and bundle were inserted
    importer = Cypress::PatientImporter.new(db)
    importer.import(mpl_file)
    assert_equal 225, Record.all.size
    assert_equal 1, db.collection("bundles").size
  end
end