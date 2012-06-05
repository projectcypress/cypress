path = File.dirname(__FILE__)
path = path.index('lib') == 0 ? "./#{path}" : path
require 'mongo'
require 'json'
require 'resque'
require 'rubygems'
require 'open-uri'


def OpenURI.redirectable?(uri1, uri2) # :nodoc:
   # This test is intended to forbid a redirection from http://... to
   # file:///etc/passwd, file:///dev/zero, etc.  CVE-2011-1521
   # https to http redirect is also forbidden intentionally.
   # It avoids sending secure cookie or referer by non-secure HTTP protocol.
   # (RFC 2109 4.3.1, RFC 2965 3.3, RFC 2616 15.1.3)
   # However this is ad hoc.  It should be extensible/configurable.
   true
   
 end
 
 
def download_measures(version)
   puts "downloading measures https://github.com/downloads/pophealth/measures/bundle_#{version}.zip"
   f =  open("https://github.com/downloads/pophealth/measures/bundle_#{version}.zip", :proxy=>ENV["http_proxy"])
puts "hey"
   return f
end

namespace :measures do

  task :setup => :environment do  
    binding.pry
    @importer = Measures::Importer.new(Mongoid.master)
    @version = ENV["M_VER"]
  end
  
  desc 'Remove the measures and bundles collection'
  task :drop_bundle => :setup do
    puts "dropping old measures"
    @importer.drop_measures
  end

   
  desc 'Remove all patient records and reload'
  task :reload_bundle => [:setup ,:drop_bundle, :load_bundle] 
 
  desc 'Remove all patient records and reload'
  task :load_bundle => [:setup ] do
    zip = download_measures(@version)  
     puts "loading measures"
     binding.pry
    @importer.import(zip)
  end


end
