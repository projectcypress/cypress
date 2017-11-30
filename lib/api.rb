module API
  module Controller
    def self.included(target)
      name = target.controller_name
      singular_name = name.singularize
      singular_json_representer = make_singular_json_representer(singular_name)
      plural_json_representer   = make_plural_json_representer(singular_json_representer)
      singular_xml_representer  = make_singular_xml_representer(singular_name)
      plural_xml_representer    = make_plural_xml_representer(singular_name, singular_xml_representer)

      target.respond_to :html
      target.respond_to :json, :xml, except: %i[new edit]
      target.represents :json, entity: singular_json_representer, collection: plural_json_representer
      target.represents :xml,  entity: singular_xml_representer,  collection: plural_xml_representer
    end

    def self.make_singular_json_representer(class_name)
      base = "#{class_name}_representer".classify.constantize
      new_module = Module.new do
        include Roar::JSON
        include Roar::Hypermedia
        include base
      end
      base.collections.each_pair { |collection_name, _| new_module.collection collection_name }
      base.embedded.each_pair do |embedded_name, embedded_vals|
        new_module.collection embedded_name, embedded: true, decorator: Class.new(Representable::Decorator) do
          embedded_vals.each do |embedded_attr|
            property embedded_attr
          end
        end
      end
      base.links.each_pair { |link_name, link_url| new_module.link link_name, &link_url }
      new_module
    end

    def self.make_singular_xml_representer(class_name)
      base = "#{class_name}_representer".classify.constantize
      new_module = Module.new do
        include Roar::XML
        include Roar::Hypermedia
        include base
      end
      base.collections.each_pair { |collection_name, collection_as| new_module.collection collection_name, wrap: collection_name, as: collection_as }
      base.embedded.each_pair do |embedded_name, embedded_vals|
        new_module.collection embedded_name, wrap: embedded_name, decorator: Class.new(Representable::Decorator) do
          embedded_vals.each do |embedded_attr|
            property embedded_attr
          end
        end
      end
      base.links.each_pair { |link_name, link_url| new_module.link link_name, &link_url }
      new_module
    end

    def self.make_plural_json_representer(singular_representer)
      Module.new do
        include Representable::JSON::Collection
        items extend: singular_representer
      end
    end

    def self.make_plural_xml_representer(class_name, singular_representer)
      Module.new do
        include Roar::XML
        include Representable::XML::Collection
        items extend: singular_representer, wrap: class_name.downcase.pluralize.underscore.to_sym
      end
    end

    def respond_with_errors(obj, &block)
      case request.format.symbol
      when :json
        render :json => serialize_json_errors(obj.errors), :status => :unprocessable_entity
      when :xml
        render :xml => serialize_xml_errors(obj.errors), :status => :unprocessable_entity
      else
        respond_with(obj, &block)
      end
    end

    def serialize_json_errors(errors)
      json = {}
      json[:errors] = errors.to_h.map { |field, messages| { :field => field, :messages => [messages].flatten } }
      json
    end

    def serialize_xml_errors(errors)
      serialize_json_errors(errors)[:errors].to_xml(:root => :errors, :skip_types => true)
    end
  end

  module Representer
    def self.included(target)
      target.include(Roar::Representer)
      target.cattr_accessor :links
      target.cattr_accessor :embedded
      target.cattr_accessor :collections
      target.links = {}
      target.embedded = {}
      target.collections = {}
    end
  end
end
