require 'quality-measure-engine'

loader = QME::Database::Loader.new()
mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')
template_dir = File.join(Rails.root, 'db', 'templates')
birthdate_dev = 60*60*24*7 # 7 days

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
      file_name = File.join(mpl_dir, "#{record['patient_id']}_#{record['first']}_#{record['last']}.json")
      file = File.new(file_name,  "w")
      file.write(JSON.pretty_generate(JSON.parse(record.to_json)))
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
  
  desc 'Remove identifiers and measure results and insert randomized name and DOB into master patient list files. Store resulting erb templates in db/templates'
  task :randomize do
    mpls = File.join(mpl_dir, '*')
    Dir.glob(mpls) do |patient_file|
      json = JSON.parse(File.read(patient_file))
      json.delete('_id')
      json.delete('patient_id')
      json.delete('measures')
      json['first'] = "<%= forename('#{json['gender']}') %>"
      json['last'] = "<%= surname %>"
      birthdate = json['birthdate']
      template = JSON.pretty_generate(json)
      template.sub!(/"birthdate": -?\d+/, "\"birthdate\": <%= between(#{birthdate-birthdate_dev}, #{birthdate+birthdate_dev}) %>")
      file_name = File.join(template_dir, "#{File.basename(patient_file)}.erb")
      file = File.new(file_name,  "w")
      file.write(template)
      file.close
    end
  end
  
end
