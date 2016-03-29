module ApiTest
  def assert_has_attributes(hash, attr_names, link_names = nil)
    attr_names.each { |key| assert hash.key?(key), "should have key #{key}" }
    if link_names
      assert_not_nil hash['links']
      assert_equal link_names.sort, hash['links'].map { |l| l['rel'] }.sort
    end
  end
end
