require 'quality-measure-engine'
require 'measure_evaluator'

loader = QME::Database::Loader.new()
mpl_dir = File.join(Rails.root, 'db', 'master_patient_list')
template_dir = File.join(Rails.root, 'db', 'templates')
birthdate_dev = 60*60*24*7 # 7 days
evaluator = Cypress::MeasureEvaluator

namespace :mpl do

  desc 'Drop all patients and cached query results'
  task :clear  => :environment do
    loader.drop_collection('records')
    loader.drop_collection('query_cache')
    loader.drop_collection('patient_cache')
    loader.drop_collection('patient_populations')
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

    # put a few standard patient populations in 
    loader.save('patient_populations', {:name => "all", :ids => Array.new(225) {|i| i.to_s}})
    loader.save('patient_populations', {:name => "core20", :ids => [201,92,20,176,30,109,82,28,5,31,189,58,57,173,188,46,55,72,81,26].collect {|x| x.to_s}})
  end
  
  desc 'Evaluate all measures for the entire master patient list'
  task :eval => :environment do
    db = loader.get_db
    Measure.installed.each do |measure|
      puts 'Evaluating measure: ' + measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + ' - ' + measure['name']
      evaluator.eval_for_static_records(measure)
    end
  end
  
  desc 'Collect a subset of "count" patients that meet the criteria for the given set of "measures"'
  task :subset => :environment do
    measures = ENV['measures'].split(',')
    num_patients = ENV['count'] ? ENV['count'].to_i : 20
    
    verbose = ENV['verbose']
    intersection = []
    initialized = false
    patient_ids = {}
    Measure.installed.each do |measure|
      if measures.any? {|m| m == measure['id']} then
        if verbose == "true" then
          print 'Patients for measure ' + measure.key + ': '
	end
	patients = Result.where('value.test_id' => nil).where('value.measure_id' => measure['id']).where('value.population' => true).each do |result|
	  if !patient_ids[measure['id']] then
	    patient_ids[measure['id']] = []
	  end
	  
	  id = result.value.medical_record_id
	  patient_ids[measure['id']].push(id)

	  if verbose == "true" then
	    print id + ' '
	  end
	end
	puts ''
      end
    end

    patient_ids.each do |k,v|
      ints = v.uniq.map {|e| e.to_i}
      v = ints.sort
      if intersection == [] then
        intersection = v
      else
        test = intersection & v
	if test.count == 0 then
	  puts '!!! there is no intersection with ' + k + ' !!!'
	else
          intersection = test 
	end
      end
      if verbose == 'true' then
        puts '=== patient IDs for ' + k + ' ==='
        v.each do |id| print id.to_s + ' ' end
        puts
      end
    end

    i = [num_patients,intersection.count].min
    puts 'Result (returning ' + i.to_s + ' of ' + intersection.count.to_s + ' records): '

    intersection.each do |id|
      i -= 1
      if i >= 0 then
      	 print id.to_s + ' '
      end
    end
    puts
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
