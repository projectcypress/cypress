require 'quality-measure-engine'
require 'fileutils'

def OpenURI.redirectable?(uri1, uri2)
  true
end

namespace :mpl do
  task :tttt do
     puts ENV.inspect
  end

  task :setup => :environment do
    @loader = QME::Database::Loader.new
    @mpl_dir = File.join(Rails.root, "db", "mpl")

    @local_installation = ENV["local_installation"] ? true : false
    @mpl_version = ENV["mpl_version"]
    @mpl_version ||= APP_CONFIG["mpl_version"]
  end
  
  desc "Download, install, and evaluate the MPL. Use measures_version (default in config/cypress.yml) and local_installation (default: false) environment variables to configure."
  task :initialize => :setup do
    task("mpl:download").execute unless @local_installation
    task("mpl:install").execute
    task("mpl:create_populations").execute
    task("mpl:evaluate").execute
  end

  desc "Download the MPL and unzip the files to the MPL directory."
  task :download => :setup do
    puts "Searching for the Master Patient List v#{@mpl_version}"
    
    # Pull down the list of bundles and select the version we're looking for
    mpl_repo = "https://api.github.com/repos/projectcypress/test-deck/downloads"
    bundles = open(mpl_repo, :proxy => ENV["http_proxy"]).read
    bundles = JSON.parse(bundles)
    bundle = choose_bundle(bundles, @mpl_version)
    
    # Download the MPL or throw an error if the requested version cannot be found
    unless bundle.nil?
      zip = open(bundle['html_url'], :proxy => ENV["http_proxy"])
    else
      puts "ERROR: Unable to download MPL v#{@mpl_version}"
      next
    end
    puts "Downloading and saving patients to #{@mpl_dir}"

    # Save the bundle to the mpl directory
    FileUtils.mkdir_p @mpl_dir
    FileUtils.mv(zip.path, File.join(@mpl_dir, "bundle_#{@mpl_version}.zip"))
  end

  desc "Install the MPL from the local db directory to the database and clear out the old one."
  task :install => :setup do
    # Throw an error if we cannot find the requested version
    mpl_file = File.join(@mpl_dir, "bundle_#{@mpl_version}.zip")
    if !File.exists?(mpl_file)
      puts "ERROR: Unable to find MPL #{@mpl_version} for installation"
      next
    end
    puts "Installing patients from #{mpl_file} to database"
    
    # Clear out all current MPL data
    @loader.get_db['bundles'].remove("name" => "Meaningful Use Stage 1 Test Deck")
    Record.where("test_id" => nil).destroy

    # Load the measures file
    mpl_file = open(mpl_file)
    Cypress::PatientImporter.new(@loader.get_db).import(mpl_file)
  end
  
  desc "Evaluate all measures for the entire master patient list. Optionally write the results to file."
  task :evaluate, [:export_to_file] => :setup do |t, args|
    args.with_defaults(:export_to_file => false)
    next if Measure.all.empty? || Record.all.empty?

    export_to_file = args[:export_to_file] == 'true'
    # Clear out the cached result data
    @loader.drop_collection('query_cache')
    @loader.drop_collection('patient_cache')
    current_results = File.new(Rails.root.join("public","current_mpl_results.txt"), "w+") if export_to_file
    puts "Evaluating all measures for the MPL"    
    Measure.installed.each do |measure|
      result = Cypress::MeasureEvaluator.eval_for_static_records(measure, false)
      if export_to_file
        current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["numerator"]:' + result['numerator'].to_s 
        current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["denominator"]:' + result['denominator'].to_s 
        current_results.puts measure['id'] + (measure['sub_id'] ? measure['sub_id'] : '') + '["exclusions"]:' + result['exclusions'].to_s
      end
    end
  end
  
  desc "Create standard populations that can be created from the MPL and clear out any old ones."
  task :create_populations => :setup do
    puts "Creating static patient populations"
    PatientPopulation.destroy_all
    
    PatientPopulation.new({
      :name => "all",
      :patient_ids => Array.new(225) {|i| i.to_s},
      :description => "Full Test Deck - 225 Records"
    }).save
    
    PatientPopulation.new({
      :name => "core20",
      :patient_ids => [201,92,20,176,30,109,82,28,5,31,189,58,57,173,188,46,55,72,81,26].collect {|x| x.to_s},
      :description => "Core and Core Alternate Subset - 20 Records"
    }).save
  end

  desc "Roll the date of every entry/property of each patient forward or backward (depending on sign) by [years]."
  task :roll, [:years, :start_date] => :setup do |t, args|
    args.with_defaults(:years => 0, :start_date => false)
    
    if args[:start_date]
      Cypress::PatientRoll.roll_effective_date(args[:start_date])
    else
      Cypress::PatientRoll.roll_year(args[:years])
    end
  end
  
  desc "Create CSV matrix of patients and their inclusion for each population of all measures."
  task :report => :setup do
    outfile = File.new(File.join("./tmp", "mpl_report.csv"), "w")
    
    # Sort all of our measures in advance by ID and sub-ID
    sorted_measures = Measure.all.entries.sort{|m1, m2| "#{m1['id']}#{m1.sub_id}" <=> "#{m2['id']}#{m2.sub_id}"}
    populations = ["population", "denominator", "numerator", "antinumerator", "exclusions"]
    
    # First write out a title line to label columns with measures
    titles = sorted_measures.collect do |measure|
      # Include a column for each population for each measure
      title = "#{measure['id']}#{measure.sub_id}"
      populations.map{|population| "#{title} #{population}"}.join(",")
    end
    titles = titles.join(",")
    outfile.write "Patient,#{titles}\n"
    
    # Print out the results for each patient per measure and population. Here a row represents a patient
    sorted_patients = Record.where("test_id" => nil).entries.sort{|p1, p2| "#{p1.last}#{p1.first}" <=> "#{p2.last}#{p2.first}"}
    sorted_patients.each do |patient|
      row = ["#{patient.first} #{patient.last}"]
      
      # Sort the results by measure ID and sub-ID so that it matches the columns
      results = Result.where("value.patient_id" => patient.id).entries
      sorted_results = results.sort{|r1, r2| "#{r1.value.measure_id}#{r1.value.sub_id}" <=> "#{r2.value.measure_id}#{r2.value.sub_id}"}
      
      # For each measure, add a 1 to the row for each population the given patient fits in. Otherwise, add a 0.
      sorted_results.each do |result|
        populations.each do |population|
          result.value[population] ? row << 1 : row << 0
        end
      end
      
      outfile.write "#{row.join(',')}\n"
    end
    
    outfile.close
  end
end
