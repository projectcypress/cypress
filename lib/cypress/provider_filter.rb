module Cypress
  class ProviderFilter
    def self.filter(providers, filters, options)
      providers.where create_query(filters, options)
    end

    def self.create_query(input_filters, _options)
      query_pieces = []

      if input_filters['npis']
        query_pieces << create_cda_ident_query(input_filters['npis'], '2.16.840.1.113883.4.6')
      end

      if input_filters['tins']
        query_pieces << create_cda_ident_query(input_filters['tins'], '2.16.840.1.113883.4.2')
      end

      if input_filters['types']
        query_pieces << { 'specialty' => { '$in' => input_filters['types'] } }
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

    def self.create_cda_ident_query(id_list, oid)
      identifiers = []
      id_list.each do |id|
        identifiers << { 'cda_identifiers' => { '$elemMatch' => { 'root' => oid, 'extension' => id } } }
      end
      { '$or' => identifiers }
    end
  end
end
