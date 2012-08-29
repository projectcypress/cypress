require 'quality-measure-engine'
require 'fileutils'
require 'open-uri'

def OpenURI.redirectable?(uri1, uri2)
  true
end

# This function is used for selecting the appropriate download option for the mpl and measures
def choose_bundle(bundles, version)
  if version.nil?
    bundles.sort! {|a,b| Date.parse(b["created_at"] ) <=> Date.parse(a["created_at"])}
    bundles.first
  else
    matches = bundles.select {|bundle| bundle["name"].include?(version)}
    matches.first
  end
end

namespace :measures do
  task :setup => :environment do
    @loader = QME::Database::Loader.new()
    @measures_dir = File.join(Rails.root, "db", "measures")
    
    @local_installation = ENV["local_installation"] ? true : false
    @measures_version = ENV["measures_version"]
    @measures_version ||= APP_CONFIG["measures_version"]
  end
  
  desc "Download, install, and evaluate all measures. Use measures_version (default in config/cypress.yml) and local_installation (default: false) environment variables to configure."
  task :initialize => :setup do
    task("measures:download").execute unless @local_installation
    task("measures:install").execute
    task("mpl:evaluate").execute
  end
  
  desc "Download the measures and unzip the files to the measures directory."
  task :download => :setup do
    puts "Searching for measures v#{@measures_version}"
    
    # Pull down the list of bundles and download the version we're looking for
    measures_repo = "https://api.github.com/repos/pophealth/measures/downloads"
    bundles = open(measures_repo, :proxy => ENV["http_proxy"]).read
    bundles = JSON.parse(bundles)
    bundle = choose_bundle(bundles, @measures_version)
    
    # Download the measures or throw an error if the requested version cannot be found
    unless bundle.nil?
      zip = open(bundle['html_url'], :proxy => ENV["http_proxy"])
    else
      puts "ERROR: Unable to download measures v#{@measures_version}"
      next
    end
    puts "Downloading and saving measures to #{@measures_dir}"
    
    # Save the bundle to the measures directory
    FileUtils.mkdir_p @measures_dir
    FileUtils.mv(zip.path, File.join(@measures_dir, "bundle_#{@measures_version}.zip"))
  end
  
  desc "Install the measures from the local db directory to the database and clear out the old ones."
  task :install => :setup do
    # Throw an error if we cannot find the requested version
    measures_file = File.join(@measures_dir, "bundle_#{@measures_version}.zip")
    if !File.exists?(measures_file)
      puts "ERROR: Unable to find measures #{@measures_version} for installation"
      next
    end
    puts "Installing measures from #{measures_file} to database #{@loader.get_db.name}"
    
    # Clear out all current measure data
    @loader.get_db['bundles'].remove("name" => "Meaningful Use Stage 1 Clinical Quality Measures")
    Measure.destroy_all
    
    # Load the measures file
    measures_file = open(measures_file)
    Measures::Importer.new(@loader.get_db).import(measures_file)
  end
end