require 'quality-measure-engine'

loader = QME::Database::Loader.new()
mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')
template_dir = File.join(Rails.root, 'db', 'templates')
birthdate_dev = 60*60*24*7 # 7 days

namespace :mpl do

  desc 'Drop all patients and cached query results'
  task :clear  => :environment do
    loader.drop_collection('records')
    loader.drop_collection('query_cache')
    loader.drop_collection('patient_cache')
  end
  
  desc 'Dump current contents of records collection to master patient list diretcory'
  task :dump => :environment do
    db = loader.get_db
    db['records'].find().each do |record|
      file_name = File.join(mpl_dir, "#{record['patient_id']}_#{record['first']}_#{record['last']}.json")
      file = File.new(file_name,  "w")
      file.write(JSON.pretty_generate(JSON.parse(record.to_json)))
      file.close
    end
  end

  desc 'Seed database with master patient list'
  task :load => [:environment, :clear] do
    mpls = File.join(mpl_dir, '*')
    Dir.glob(mpls) do |patient_file|
      json = JSON.parse(File.read(patient_file))
      if json['_id']
        json['_id'] = BSON::ObjectId.from_string(json['_id'])
      end
      loader.save('records', json)
    end
  end
  
  desc 'Remove identifiers and measure results and insert randomized name and DOB into master patient list files. Store resulting erb templates in db/templates'
  task :randomize  => :environment do
    mpls = File.join(mpl_dir, '*')
    Dir.glob(mpls) do |patient_file|
      json = JSON.parse(File.read(patient_file))
      json.delete('_id')
      json.delete('patient_id')
      json.delete('measures')
      json['first'] = "<%= forename('#{json['gender']}') %>"
      json['last'] = "<%= surname %>"
      json['events'] = {}
      %w{encounters conditions medications medical_equipment allergies social_history vital_signs results procedures immunizations care_goals}.each do |section|
        json['events'][section] ||= []
        json[section].each do |entry|
          event = {}
          event['description'] = entry['description']
          event['time'] = entry['time']
          event['code_set'] = entry['codes'].keys[0]
          event['code'] = entry['codes'][event['code_set']][0]
          if entry['status']
            event['status'] = entry['status']
          end
          if entry['value']
            event['value'] = entry['value']['scalar']
          end
          json['events'][section] << event
        end
        json.delete(section)
      end
      %w{active inactive resolved}.each do |section|
        json.delete(section)
      end
      birthdate = json['birthdate']
      template = JSON.pretty_generate(json)
      template.sub!(/"birthdate": -?\d+/, "\"birthdate\": <%= between(#{birthdate-birthdate_dev}, #{birthdate+birthdate_dev}) %>")
#      template.sub!(/"addresses": .*,/, "\"addresses\": [<%= address %>],")
      file_name = File.join(template_dir, "#{File.basename(patient_file)}.erb")
      file = File.new(file_name,  "w")
      file.write(template)
      file.close
    end
  end
  
end
