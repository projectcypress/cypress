module Cypress
  class BundleImportJob

    attr_accessor :options

    def initialize(options)
      @options = options
    end

    def perfrom
      bundle = File.open(options[:bundle_path])
      importer = QME::Bundle::Importer.new(db_name)
      bundle_contents = importer.import(bundle, options[:delete_existing])

    end

  end

end
