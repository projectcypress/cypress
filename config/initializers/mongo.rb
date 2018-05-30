module QME
  Mongoid.logger.level = Logger::INFO
  Mongoid.logger = Rails.logger if ENV['MONGO_LOGS'].eql? 'true'
  Mongo::Logger.logger.level = Logger::WARN
  Mongo::Logger.logger = Rails.logger if ENV['MONGO_LOGS'].eql? 'true'
  BSON::Config.validating_keys = false
end
