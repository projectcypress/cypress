require 'test_helper'

class EntryTest < ActiveSupport::TestCase
  test "should know if it is single valued" do
    e = Entry.new
    e.codes = {"CPT" => [1234]}
    assert e.single_code_value?

    e.codes = {"CPT" => [1234, 4567]}
    assert ! e.single_code_value?

    e.codes = {"CPT" => [1234], "ICD-9" => [2345]}
    assert ! e.single_code_value?
  end
end