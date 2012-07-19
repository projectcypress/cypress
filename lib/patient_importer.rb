module Cypress
  # Formerly a resque job, this will now read a zip file located in the db/mpl directory and import the MPL into the records collection.
  # This class will be renamed shortly 
  class PatientImporter
    # Create a new PatientImporter.
    #
    # @param [String] db_name the name of the database to use
    def initialize(db)
      @db = db
    end
    
    # Reads an MPL bundle downloaded from the test-deck repository and stores the Records in the DB
    #
    # @param [File] zip The bundle file that we are importing
    def import(zip)
      # Read the zip
      Zip::ZipFile.open(zip.path) do |zipfile|
        zipfile.each do |file|
          # Ignore any directories that we find as well as those annoying ._ files from OSX
          if file.name.include?(".json") && !file.name.include?("._")
            if file.name.include?("bundle.json")
              @db['bundles'] << JSON.parse(zipfile.read(file))
            else
              patient = JSON.parse(zipfile.read(file))
              patient['_id'] = BSON::ObjectId.from_string(patient['_id']) if patient['_id']
              Record.new(patient).save
            end
          end
        end
      end
    end
    
  end
end