path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'mongo'
require 'json'
require 'resque'
require 'rubygems'
require 'open-uri'

DOWNLOADS_ROOT = "https://api.github.com/repos/pophealth/measures/downloads"
def OpenURI.redirectable?(uri1, uri2) # :nodoc:
   # This test is intended to forbid a redirection from http://... to
   # file:///etc/passwd, file:///dev/zero, etc.  CVE-2011-1521
   # https to http redirect is also forbidden intentionally.
   # It avoids sending secure cookie or referer by non-secure HTTP protocol.
   # (RFC 2109 4.3.1, RFC 2965 3.3, RFC 2616 15.1.3)
   # However this is ad hoc.  It should be extensible/configurable.
   true
   
 end
 


namespace :measures do

  task :setup => :environment do  
    @db =  Mongoid.master
    @loader = QME::Database::Loader.new()
     @importer = Measures::Importer.new(@db)
  end
  

 
  desc 'Remove all patient records and reload'
  task :update => [:setup ] do
     
    str = open("https://api.github.com/repos/pophealth/measures/downloads", :proxy=>ENV["http_proxy"]).read
    json = JSON.parse(str)
    json.sort! {|a,b|  
        Date.parse(b["created_at"] ) <=> Date.parse(a["created_at"])
    }
    begin
      
      entry =  json[0]
      if entry
         puts "updating to measures #{entry['name']}"
         f = open(entry['html_url'])
         puts "importing measures"

         @importer.import(f)
         @db['patient_cache'].remove({"test_id" => nil})
         @db['query_cache'].remove({"test_id" => nil})
         Rake::Task['mpl:eval'].invoke()
      else
        puts "No measures found"
      end
    rescue
        puts $!.backtrace
    end
   
  end

  desc 'Load the local bundle.zip'
  task :load_local_bundle, [:bundle_name] => [:setup ] do |t, args|
    bundle_name = args[:bundle_name] || 'bundle'
    @loader.drop_collection("measures")
    @importer.import(File.new("./db/" + bundle_name + ".zip"))
  end


end
