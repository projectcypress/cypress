require 'test_helper'
require 'fileutils'

class NameRandomizerTest < ActiveSupport::TestCase
  setup do
    @pt = FactoryBot.create(:product_test_static_result)
    record1 = Patient.new(givenNames: ['AA'], familyName: 'BB', extendedData: { 'correlation_id' => @pt.id })
    record1.save
    @prng = Random.new(Random.new_seed)
  end

  def test_randomize_no_nickname
    nickname = Cypress::NameRandomizer.safe_nickname(nil, 'AAA', 'BB', @pt.patients, random: @prng)
    assert_equal 'A', nickname
  end

  def test_randomize_matching_nickname
    nickname = Cypress::NameRandomizer.safe_nickname(['AA'], 'AAA', 'BB', @pt.patients, random: @prng)
    assert_equal 'A', nickname
  end

  def test_randomize_unique_nickname
    nickname = Cypress::NameRandomizer.safe_nickname(['AAAA'], 'AAA', 'BB', @pt.patients, random: @prng)
    assert_equal 'AAAA', nickname
  end
end
