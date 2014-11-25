require 'test_helper'
class ValuesetValidatorTest < ActiveSupport::TestCase

   setup do

    collection_fixtures('bundles', '_id')
    collection_fixtures('health_data_standards_svs_value_sets', '_id','bundle_id')
    @bundle = Bundle.find("4fdb62e01d41c820f6000001")
    @validator = Validators::ValuesetValidator.new(@bundle)
   end

   test "Should produce errors for unknown valuesets or values not found in vs" do
      xml = File.open("./test/fixtures/validators/valuesets/bad.xml","r") do |f| f.read() end
      @validator.validate(xml)
      assert_equal 2,  @validator.errors.length, "File should contain 2 errors"
   end

   test "Should not produce errors for files for all " do
      xml = File.open("./test/fixtures/validators/valuesets/good.xml","r") do |f| f.read() end
      @validator.validate(xml)
      assert_equal  0,  @validator.errors.length, "File should not contain any errors"
   end

end
