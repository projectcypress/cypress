require 'quality-measure-engine'

loader = QME::Database::Loader.new()
mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')

namespace :mpl do

  desc 'Drop all patients and cached query results'
  task :clear do
    loader.drop_collection('records')
    loader.drop_collection('query_cache')
    loader.drop_collection('patient_cache')
  end
  
  desc 'Dump current contents of records collection to master patient list diretcory'
  task :dump do
    db = loader.get_db
    db['records'].find().each do |record|
      file_name = File.join(mpl_dir, "#{record['patient_id']}_#{record['first']}_#{record['last']}")
      file = File.new(file_name,  "w")
      file.write(record.to_json)
      file.close
    end
  end

  desc 'Seed database with master patient list'
  task :load => :clear do
    mpls = File.join(mpl_dir, '*')
    Dir.glob(mpls) do |patient_file|
      json = JSON.parse(File.read(patient_file))
      loader.save('records', json)
    end
  end
  
  desc 'Insert randomized name and DOB into master patient list and store in db/templates'
  task :randomize do
    
  end
  
end
