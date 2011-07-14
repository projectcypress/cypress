require 'test_helper'
require 'ostruct'

class C32ExportTest < ActiveSupport::TestCase
  setup do
    @pi = QME::Importer::PatientImporter.instance
  end
  
  test "generating a CDA header" do
    person = OpenStruct.new(:first => 'Bobby', :last => 'Tables',
                            :gender => 'M', :birthdate => 0)
    person.class_eval {include C32Export}
    doc = Nokogiri::XML(person.to_c32)
    parsed = {}
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    @pi.get_demographics(parsed, doc)

    assert_equal 'Bobby', parsed['first']
    assert_equal 'Tables', parsed['last']
    assert_equal 'M', parsed['gender']
    assert_equal 0, parsed['birthdate']
  end
end