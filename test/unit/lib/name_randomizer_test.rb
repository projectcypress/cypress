require 'test_helper'
require 'fileutils'

class NameRandomizerTest < ActiveSupport::TestCase
  setup do
    @pt = FactoryBot.create(:product_test_static_result)
    record1 = @pt.patients.first.clone
    record1.update(givenNames: ['AA'], familyName: 'BB')
    @prng = Random.new(Random.new_seed)
  end

  def test_randomize_augmented_record
    augmented_patients = [{ first: %w[AA A], last: %w[BB BB] }]
    patient_to_clone = @pt.patients.where(familyName: 'BB').first.clone
    20.times do
      Cypress::NameRandomizer.randomize_patient_name_first(patient_to_clone, augmented_patients, random: @prng)
      assert_not_equal ['A'], patient_to_clone.givenNames
    end
  end

  def test_randomize_no_nickname
    nickname = Cypress::NameRandomizer.nickname(nil, 'AAA', random: @prng)
    assert_equal 'A', nickname
  end

  def test_randomize_unique_nickname
    nickname = Cypress::NameRandomizer.nickname(['AAAA'], 'AAA', random: @prng)
    assert_equal 'AAAA', nickname
  end
end
