MONGO_DB = Mongoid.database

require 'cypress'
require 'validation'
require 'validation_error'
require 'validators/schema_validator'
require 'validators/schematron_validator'

XML_VALIDATION_INSPECTION="XmlValidationInspection"


MONGO_DB = Mongoid.database
# insert races and ethnicities
(
  MONGO_DB['races'].drop() if MONGO_DB['races']
  MONGO_DB['ethnicities'].drop() if MONGO_DB['ethnicities']
  JSON.parse(File.read(File.join(Rails.root, 'test', 'fixtures', 'code_sets', 'races.json'))).each do |document|
    MONGO_DB['races'].save(document)
  end
  JSON.parse(File.read(File.join(Rails.root, 'test', 'fixtures', 'code_sets', 'ethnicities.json'))).each do |document|
    MONGO_DB['ethnicities'].save(document)
  end
) if MONGO_DB['races'].count == 0 || MONGO_DB['ethnicities'].count == 0

# insert languages
(
  JSON.parse(File.read(File.join(Rails.root, 'test', 'fixtures', 'code_sets', 'languages.json'))).each do |document|
    MONGO_DB['languages'].save(document)
  end
) if MONGO_DB['languages'].count == 0
