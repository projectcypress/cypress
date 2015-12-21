require 'test_helper'
require 'fileutils'
require 'pry'

class ProviderFilterTest < ActiveSupport::TestCase
  def setup
    collection_fixtures('providers')

    @all_providers = Provider.all
  end

  def test_filter_tin
    selected_tin = '897230473'

    filters = { 'tins' => [selected_tin] }

    filtered_providers = Cypress::ProviderFilter.filter(@all_providers, filters, {}).to_a

    assert filtered_providers.count > 0, 'should have found the provider with the given tin'

    @all_providers.each do |p|
      if filtered_providers.include? p
        assert_equal selected_tin, p['tin'], 'Filtered record set includes a record that does not match criteria'
      else
        assert_not_equal selected_tin, p['tin'], 'Filtered record set does not include a record that matches criteria'
      end
    end
  end

  def test_filter_npi
    selected_npi = '1480614951'

    filters = { 'npis' => [selected_npi] }

    filtered_providers = Cypress::ProviderFilter.filter(@all_providers, filters, {}).to_a

    assert filtered_providers.count > 0, 'should have found the provider with the given npi'

    @all_providers.each do |p|
      if filtered_providers.include? p
        assert_equal selected_npi, p['npi'], 'Filtered record set includes a record that does not match criteria'
      else
        assert_not_equal selected_npi, p['npi'], 'Filtered record set does not include a record that matches criteria'
      end
    end
  end

  def test_filter_type
    selected_type = 'ep'

    filters = { 'types' => [selected_type] }

    filtered_providers = Cypress::ProviderFilter.filter(@all_providers, filters, {}).to_a

    assert filtered_providers.count > 0, 'should have found a provider with the given type'

    @all_providers.each do |p|
      if filtered_providers.include? p
        assert_equal selected_type, p['type'], 'Filtered record set includes a record that does not match criteria'
      else
        assert_not_equal selected_type, p['type'], 'Filtered record set does not include a record that matches criteria'
      end
    end
  end

  def test_filter_address
    selected_addr = { 'street' => '202 Burlington Rd', 'city' => 'Bedford', 'state' => 'MA', 'zip' => '01730', 'country' => 'US' }

    filters = { 'addresses' => [selected_addr] }

    filtered_providers = Cypress::ProviderFilter.filter(@all_providers, filters, {}).to_a

    assert filtered_providers.count > 0, 'should have found a provider with the given address'

    @all_providers.each do |p|
      should_be_included = address_in_list(selected_addr, p['addresses'])

      if filtered_providers.include? p
        assert should_be_included, 'Filtered record set includes a record that does not match criteria'
      else
        assert_not should_be_included, 'Filtered record set does not include a record that matches criteria'
      end
    end
  end

  def test_filter_combination
    selected_tin = '020700270'
    selected_npi = '1520670765'
    selected_addr = { 'street' => '100 Bureau Drive', 'city' => 'Gaithersburg', 'state' => 'MD', 'zip' => '20899', 'country' => 'US' }

    filters = { 'tins' => [selected_tin], 'npis' => [selected_npi], 'addresses' => [selected_addr] }

    filtered_providers = Cypress::ProviderFilter.filter(@all_providers, filters, {}).to_a

    assert filtered_providers.count > 0, 'should have found a provider with the given npi/tin/address'

    @all_providers.each do |p|
      should_be_included = p['npi'] == selected_npi &&
                           p['tin'] == selected_tin &&
                           address_in_list(selected_addr, p['addresses'])

      if filtered_providers.include? p
        assert should_be_included, 'Filtered record set includes a record that does not match criteria'
      else
        assert_not should_be_included, 'Filtered record set does not include a record that matches criteria'
      end
    end
  end

  def address_in_list(addr, addr_list)
    return false unless addr_list

    addr_list.each do |curr|
      return true if curr['street'].include?(addr['street']) &&
                     curr['city'] == addr['city'] &&
                     curr['state'] == addr['state'] &&
                     curr['zip'] == addr['zip'] &&
                     curr['country'] == addr['country']
    end
    false
  end
end
