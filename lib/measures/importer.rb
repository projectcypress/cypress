module Measures
  
  # Utility class for working with JSON files and the database
  class Importer
   
    # Create a new Importer.
    def initialize(db)
     @db = db
    end
    
    def import(zip)

      entries_by_type = {
        libraries: {},
        bundle: nil,
        json: {}
      }
      
       Zip::ZipFile.open(zip.path) do |zipfile|
        zipfile.entries.each do |entry|
          next if entry.directory? 
          entries_by_type[:libraries][entry_key(entry.name,"js")] = zipfile.read(entry.name) if entry.name.match /libraries\// 
          entries_by_type[:json][entry_key(entry.name,"json")] = zipfile.read(entry.name) if entry.name.match /json\// 
          entries_by_type[:bundle] = zipfile.read(entry.name) if entry.name.match /bundle/ 
        end
      end
      
      bundle_def = JSON.parse(entries_by_type[:bundle])
      bundle_def["extensions"] ||=[]
      bundle_def["measures"] ||=[]

      entries_by_type[:libraries].each do |key,contents|
        bundle_def["extensions"] << key
        save_system_js_fn(key, contents)
      end

      measure_defs = []
      entries_by_type[:json].each do |key, contents|
        measure_def = JSON.parse(contents, {:max_nesting => 100})
        measure_def["_id"] = @db['measures'] << measure_def
        bundle_def['measures'] << measure_def["_id"]
        measure_defs << measure_def
      end
      
      bundle_id = @db['bundles'] << bundle_def
      
      measure_defs.each do |measure_def|
        measure_def['bundle'] = bundle_id
        @db['measures'].update({"_id" => measure_def["_id"]}, measure_def)
      end
      
      measure_defs.count
      
    end
    
    def drop_measures
      drop_collection('bundles')
      drop_collection('measures')
      drop_collection('patient_cache')
      drop_collection('query_cache')
    end
    
    def drop_collection(collection)
      if collection == 'bundles'
        @db[collection].remove({"name" => "Meaningful Use Stage 1 Clinical Quality Measures"})
      else
        @db[collection].drop
      end
    end
    
    def save_system_js_fn(name, fn)

      fn = "function () {\n #{fn} \n }"

      @db['system.js'].save(
        {
          "_id" => name,
          "value" => BSON::Code.new(fn)
        }
      )
    end
    
    private 
    
    def entry_key(original, extension)
      original.split('/').last.gsub(".#{extension}",'')
    end
    
  end
end