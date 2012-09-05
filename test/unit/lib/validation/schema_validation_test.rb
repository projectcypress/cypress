class SchemaValidatorTest < ActiveSupport::TestCase

  def test_invalid_file
      xml = File.open("./test/fixtures/validators/addressbook_id_bad.xml","r") do |f| f.read() end
      processor = Validators::Schema::Validator.new("something","./test/fixtures/validators/addressbook_id.xsd")
      assert processor.validate(Nokogiri::XML(xml)).length >=1, "File should not validate"
   end

   def test_valid_file 
      xml = File.open("./test/fixtures/validators/addressbook_id.xml","r") do |f| f.read() end
      processor = Validators::Schema::Validator.new("something","./test/fixtures/validators/addressbook_id.xsd")
      assert processor.validate(Nokogiri::XML(xml)).length == 0, " There should be 0 errors for a valid file"
   end
  
  
end
