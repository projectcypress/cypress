require 'representable/xml'
module ProductTestRepresenter
  include API::Representer

  property :name
  property :cms_id
  property :measure_id, getter: ->(_args) { measure_ids.first }
  property :type, getter: ->(_args) { _type == 'MeasureTest' ? 'measure' : 'filter' }
  property :state
  property :created_at

  module ProviderRepresenter
    include Representable::XML
    include Representable::JSON

    module AddressRepresenter
      include Representable::XML
      include Representable::JSON

      self.representation_wrap = ->(obj) { obj.key?(:doc) ? :address : false }

      property :street, getter: ->(_) { self['street'].first }
      property :city
      property :state
      property :zip, getter: -> (_) { self['zip'] }
      property :country
    end

    self.representation_wrap = ->(obj) { obj.key?(:doc) ? :provider : false }

    property :npi, getter: ->(_) { self['npis'].first }
    property :tin, getter: ->(_) { self['tins'].first }
    property :address, extend: AddressRepresenter, if: ->(_) { self['addresses'] }, getter: ->(_) { self['addresses'].first }
  end

  hash :provider_filters, :if => ->(_) { _type == 'FilteringTest' && options.filters.key?('providers') && state == :ready }, :wrap => :filters,
                          :as => :filters, :extend => ProviderRepresenter,
                          :getter => (lambda do |*|
                            filters_copy = options.filters.clone
                            filters_copy['provider'] = filters_copy.delete 'providers'
                            filters_copy
                          end)

  hash :problem_filters,
       :getter => ->(_) { options.filters.map { |filter_type, filter_val| [filter_type.to_s.singularize, filter_val['oid'].first] }.to_h },
       :if => ->(_) { _type == 'FilteringTest' && options.filters.key?('problems') && state == :ready },
       :wrap => :filters, :as => :filters

  hash :other_filters, :getter => ->(_) { options.filters.map { |filter_type, filter_val| [filter_type.to_s.singularize, filter_val.first] }.to_h },
                       :if => ->(_) { _type == 'FilteringTest' && !options.filters['providers'] && !options.filters['problems'] && state == :ready },
                       :wrap => :filters, :as => :filters

  self.links = {
    self: proc { product_product_test_path(product, self) },
    tasks: proc { product_test_tasks_path(self) },
    patients: proc { patients_product_test_path(self) }
  }
end
