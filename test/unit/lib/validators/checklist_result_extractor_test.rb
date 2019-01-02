require 'test_helper'
class ChecklistResultExtractorTest < ActiveSupport::TestCase
  def setup
    @object = Object.new
    @object.extend(Validators::ChecklistResultExtractor)
  end

  def test_template_nodes_no_reason
    source_criteria = {  'title' => 'Decision to Admit to Hospital Inpatient',
                         'definition' => 'encounter',
                         'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.295',
                         'attributes' => [{ 'attribute_name' => 'authorDatetime', 'attribute_valueset' => nil }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => '19951005',
                         'recorded_result' => '105480006',
                         'negated_valueset' => false }
    template = '2.16.840.1.113883.10.20.24.3.22'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    # If a source, does not have a reason return false and a document with the root of 'section'
    assert_equal false, reason_template
    assert_equal 'section', nodes[0].root.name
  end

  def test_check_attribute_false_reason
    source_criteria = {  'title' => 'Decision to Admit to Hospital Inpatient',
                         'definition' => 'encounter',
                         'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.295',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => '6',
                         'attribute_code' => '24',
                         'negated_valueset' => false,
                         'attribute_complete' => true }
    template = '2.16.840.1.113883.10.20.24.3.22'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    # You do not need to check an attribute when the source criteria has a negationRationale or Reason
    assert_equal false, @object.check_attribute?
  end

  def test_check_attribute_false
    source_criteria = {  'title' => 'Decision to Admit to Hospital Inpatient',
                         'definition' => 'encounter',
                         'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.295' }
    checked_criteria = { 'attribute_complete' => nil,
                         'result_complete' => nil }
    template = '2.16.840.1.113883.10.20.24.3.22'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    # You do not need to check an attribute when the attribute or result have not been completed (this is an input from in the UI)
    assert_equal false, @object.check_attribute?
  end

  def test_check_attribute_true
    source_criteria = {  'title' => 'Decision to Admit to Hospital Inpatient',
                         'definition' => 'encounter',
                         'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.295',
                         'attributes' => [{ 'attribute_name' => 'authorDatetime', 'attribute_valueset' => nil }] }
    checked_criteria = { 'attribute_complete' => true,
                         'attribute_index' => 0,
                         'code' => '6' }
    template = '2.16.840.1.113883.10.20.24.3.22'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    # You do need to check an attribue when a source criteria has an attribute, and it is referenced in teh checked_criteria
    assert_equal true, @object.check_attribute?
  end

  def test_template_nodes_with_reason
    source_criteria = {  'title' => 'Anti-HypertensivePharmacologicTherapy',
                         'definition' => 'medication',
                         'code_list_id' => '1.1.2.3',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => '6',
                         'attribute_code' => '24',
                         'negated_valueset' => false }
    template = '2.16.840.1.113883.10.20.24.3.47'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    # Returns true for source criteria with negationRationale
    assert_equal true, reason_template
    # Returns 1 node that has the negation code in the checked_criteria
    assert_equal 1, nodes.size
  end

  def test_template_nodes_with_wrong_reason_code
    source_criteria = {  'title' => 'Anti-HypertensivePharmacologicTherapy',
                         'definition' => 'medication',
                         'code_list_id' => '1.1.2.3',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => '6',
                         'attribute_code' => '25',
                         'negated_valueset' => false }
    template = '2.16.840.1.113883.10.20.24.3.47'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    # Returns true for source criteria with negationRationale
    assert_equal true, reason_template
    # Returns 1 node that has the negation code in the checked_criteria
    assert_equal 0, nodes.size
  end

  def test_find_template_with_code_correct_negated_code
    source_criteria = {  'title' => 'Anti-HypertensivePharmacologicTherapy',
                         'definition' => 'medication',
                         'code_list_id' => '1.1.2.3',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => '6',
                         'attribute_code' => '24',
                         'negated_valueset' => false }
    template = '2.16.840.1.113883.10.20.24.3.47'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    codenodes = @object.find_template_with_code(nodes, reason_template)
    # One entry contains the correct code,negation code and template
    assert_equal 1, codenodes.size
  end

  def test_find_template_with_code_correct_negated_code_incorrect_template
    source_criteria = {  'title' => 'Anti-HypertensivePharmacologicTherapy',
                         'definition' => 'medication',
                         'code_list_id' => '1.1.2.3',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => '6',
                         'attribute_code' => '24',
                         'negated_valueset' => false }
    template = '2.16.840.1.113883.10.20.24.3.46'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    codenodes = @object.find_template_with_code(nodes, reason_template)
    # 1 Node has the correct negation code
    assert_equal 1, nodes.size
    # 0 Nodes have the correction negation code and template
    assert_equal 0, codenodes.size
  end

  def test_find_template_with_code_correct_negated_vs
    source_criteria = {  'title' => 'Anti-HypertensivePharmacologicTherapy',
                         'definition' => 'medication',
                         'code_list_id' => '1.1.2.3',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => nil,
                         'attribute_code' => '24',
                         'negated_valueset' => true }
    template = '2.16.840.1.113883.10.20.24.3.47'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries_negated_vs.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    codenodes = @object.find_template_with_code(nodes, reason_template, source_criteria['code_list_id'])
    # One entry contains the correct valueset,negation code and template
    assert_equal 1, codenodes.size
  end

  def test_find_template_with_code_incorrect_negated_vs
    source_criteria = {  'title' => 'Anti-HypertensivePharmacologicTherapy',
                         'definition' => 'medication',
                         'code_list_id' => '1.1.2.4',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => nil,
                         'attribute_code' => '24',
                         'negated_valueset' => true }
    template = '2.16.840.1.113883.10.20.24.3.47'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries_negated_vs.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    codenodes = @object.find_template_with_code(nodes, reason_template, source_criteria['code_list_id'])
    # 1 Node has the correct negation code
    assert_equal 1, nodes.size
    # 0 Nodes have the correction negation code and template
    assert_equal 0, codenodes.size
  end

  def test_find_template_with_code_and_reason_in_different_entries
    source_criteria = {  'title' => 'Decision to Admit to Hospital Inpatient',
                         'definition' => 'encounter',
                         'code_list_id' => '2.16.840.1.113883.3.117.1.7.1.295',
                         'attributes' => [{ 'attribute_name' => 'negationRationale', 'attribute_valueset' => '1.2.3.4' }] }
    checked_criteria = { 'attribute_index' => 0,
                         'code' => '19951005',
                         'attribute_code' => '24',
                         'negated_valueset' => false }
    template = '2.16.840.1.113883.10.20.24.3.22'
    file = File.new(Rails.root.join('test', 'fixtures', 'qrda', 'checklist', 'multiple_entries_negated_vs.xml')).read
    doc = get_document(file)
    @object.instance_variable_set(:@source_criteria, source_criteria)
    @object.instance_variable_set(:@checked_criteria, checked_criteria)
    @object.instance_variable_set(:@template, template)
    @object.instance_variable_set(:@file, doc)
    reason_template, nodes = @object.template_nodes
    codenodes = @object.find_template_with_code(nodes, reason_template)
    # 1 Node has the correct negation code
    assert_equal 1, nodes.size
    # 0 Nodes have the correction negation code and template
    assert_equal 0, codenodes.size
  end

  def get_document(input)
    doc = Nokogiri::XML(input)
    doc.root.add_namespace_definition('', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
    doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
    doc
  end
end
