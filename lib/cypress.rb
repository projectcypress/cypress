Dir[File.dirname(__FILE__) + '/cypress/*.rb'].each {|file| require file }.each {|file| 
  puts file
  require file }