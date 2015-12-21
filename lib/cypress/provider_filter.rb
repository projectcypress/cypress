module Cypress
  class ProviderFilter
    def self.filter(providers, filters, options)
      providers.where create_query(filters, options)
    end

    def self.create_query(input_filters, _options)
      query_pieces = []

      if input_filters['npis']
        query_pieces << { 'npi' => { '$in' => input_filters['npis'] } }
      end

      if input_filters['tins']
        query_pieces << { 'tin' => { '$in' => input_filters['tins'] } }
      end

      if input_filters['types']
        query_pieces << { 'type' => { '$in' => input_filters['types'] } }
      end

      if input_filters['addresses']
        query_pieces << create_address_query(input_filters['addresses'])
      end

      { '$and' => query_pieces }
    end

    def self.create_address_query(address_filters)
      # address_filters = list of hashes
      address_query_pieces = address_filters.collect { |addr| { 'addresses' => { '$elemMatch' => addr } } }
      { '$or' => address_query_pieces }
    end
  end
end
