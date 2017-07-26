require 'test_helper.rb'
class DefaultProviderTest < MiniTest::Test
  def test_default_provider
    assert Provider.default_provider, 'should have created default provider'
  end

  def test_generate_provider
    assert Provider.generate_provider, 'should have generated a provider'
  end

  def test_ccn_length
    prov = Provider.generate_provider
    assert_equal 6, prov.ccn.length, 'Generated CCN should have exactly 6 characters'
    assert Provider.valid_npi?(prov.npi), 'Generated NPI Should be valid'
  end
end
