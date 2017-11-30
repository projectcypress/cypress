module ApiTest
  def assert_has_attributes(hash, attr_names, link_names = nil)
    attr_names.each { |key| assert hash.key?(key), "should have key #{key}" }
    if link_names
      assert_not_nil hash['links']
      assert_equal link_names.sort, hash['links'].map { |l| l['rel'] }.sort
    end
  end

  def assert_has_json_errors(hash, errors = nil)
    assert hash.key? 'errors'
    errors&.each do |field, messages|
      assert hash['errors'].any? { |error| error['field'] == field }, "error response should have field #{field}"
      assert hash['errors'].any? { |error| error['messages'] == messages }, "error response should have messages #{messages}"
    end
  end

  def assert_has_xml_errors(hash, errors = nil)
    assert hash.key? 'errors'
    errors&.each do |field, messages|
      assert hash['errors'].any? { |_, v| v['field'] == field }, "error response should have field #{field}"
      assert hash['errors'].any? { |_, v| v['messages'].any? { |_mk, mv| messages.include? mv } }, "error response should have messages #{messages}"
    end
  end
end
