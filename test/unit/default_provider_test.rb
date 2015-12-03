require 'test_helper.rb'
class DefaultProviderTest < MiniTest::Test
  def test_default_provider
    assert Provider.default_provider, 'should have created default provider'
  end

  def test_generate_provider
    assert Provider.generate_provider, 'should have generated a provider'
  end
end
