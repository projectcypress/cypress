require 'mongo'

host = ENV['TEST_DB_HOST'] || 'localhost'
conn = Mongo::Connection.new(host, 27017)

MONGO_DB = conn["cypress_#{Rails.env}"]

module QME
  module DatabaseAccess
    # Monkey patch in the connection for the application
    def get_db
      MONGO_DB
    end
  end
end
