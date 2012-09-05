class SchematronValidatorTest < ActiveSupport::TestCase
  

  def test_compiled_validator

      validator = Validators::Schematron::CompiledValidator.new("test validator", File.open("./test/fixtures/validators/compiled_schematron.xsl"))
      xml = File.open("./test/fixtures/validators/schematron_test_good.xml","r") do |f| f.read() end
      assert validator.validate(nil,Nokogiri::XML(xml)).length == 0



      validator = Validators::Schematron::CompiledValidator.new("test validator", File.open("./test/fixtures/validators/compiled_schematron.xsl"))
      xml = File.open("./test/fixtures/validators/schematron_test_bad.xml","r") do |f| f.read() end
      errors = validator.validate(nil,Nokogiri::XML(xml))
      assert errors.length > 0
      assert errors.first.message == "An element of type dog should have an id attribute that is a unique identifier for that animal."

  end

   def test_uncompiled_validator


      validator = Validators::Schematron::UncompiledValidator.new("test validator", File.open("./test/fixtures/validators/schematron_rules.xml"),File.open("./test/fixtures/validators/schematron_1.5_svrl_new.xsl"))
      xml = File.open("./test/fixtures/validators/schematron_test_good.xml","r") do |f| f.read() end
      assert validator.validate(nil,Nokogiri::XML(xml)).length ==0 


      validator = Validators::Schematron::UncompiledValidator.new("test validator", File.open("./test/fixtures/validators/schematron_rules.xml"),File.open("./test/fixtures/validators/schematron_1.5_svrl_new.xsl"))
      xml = File.open("./test/fixtures/validators/schematron_test_bad.xml","r") do |f| f.read() end
      assert validator.validate(nil,Nokogiri::XML(xml)).length >=0

    end
  
  
end