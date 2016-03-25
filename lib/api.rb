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
      target.respond_to :json, :xml, except: [:new, :edit]
      target.represents :json, entity: singular_json_representer, collection: plural_json_representer
      target.represents :xml,  entity: singular_xml_representer,  collection: plural_xml_representer
    end

    def self.make_singular_json_representer(class_name)
      base = "#{class_name}_representer".classify.constantize
      new_module = Module.new do
        include Roar::JSON::HAL
        include base
      end
      base.links.each_pair { |link_name, link_url| new_module.link link_name, &link_url }
      base.embedded.each_pair do |embedded_name, embedded_vals|
        new_module.collection embedded_name, embedded: true, decorator: Class.new(Representable::Decorator) do
          embedded_vals.each do |embedded_attr|
            property embedded_attr
          end
        end
      end
      new_module
    end

    def self.make_singular_xml_representer(class_name)
      base = "#{class_name}_representer".classify.constantize
      new_module = Module.new do
        include Roar::XML
        include Roar::Hypermedia
        include base
      end
      base.links.each_pair { |link_name, link_url| new_module.link link_name, &link_url }
      base.embedded.each_pair do |embedded_name, embedded_vals|
        new_module.collection embedded_name, wrap: embedded_name, decorator: Class.new(Representable::Decorator) do
          embedded_vals.each do |embedded_attr|
            property embedded_attr
          end
        end
      end
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
        include Representable::JSON::Collection
        items extend: singular_representer, wrap: class_name.downcase.pluralize.underscore.to_sym
      end
    end
  end

  module Representer
    def self.included(target)
      target.include(Roar::Representer)
      target.cattr_accessor :links
      target.cattr_accessor :embedded
    end
  end
end
