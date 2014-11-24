module Validators
  module Schematron
    NAMESPACE = {"svrl" => "http://purl.oclc.org/dsdl/svrl"}
    # base validator class, handles the acutal validation process as it's common between the compiled (XSLT pre computed)
    # and the uncompiled (Do a transform of the schematron rules resulting in a stylesheet and use that stylesheet to do the validation)
    class BaseValidator

      # validate the document, This performs the XSLT transform on the document and then looks for any errors in the
      # resulting doc, errors show up as failed-assert elements in the result.
      def validate(document,data = {})
           document = Nokogiri::XML(document.to_s) unless document.kind_of?(Nokogiri::XML::Document)
           errors = []
           style = get_schematron_processor
           # process the document
           report = style.transform(document)
           # create an REXML::Document form the results
           # report = Nokogiri::XML(result)
           # loop over failed assertions
           report.root.xpath("//svrl:failed-assert",NAMESPACE).each do |el|

             # do something here with the values
             errors << ExecutionError.new(
               :location => el["location"],
               :message => el.xpath('svrl:text',NAMESPACE).text,
               :validator => name,
               :validator_type => :xml_validation,
               :msg_type=>(data[:msg_type] || :error),
               :file_name => data[:file_name],
               :measure_id => data[:measure_id]
             )

           end
           errors.uniq{|e| "#{e.location}#{e.message}"}
      end

        # stubbed method needed to obtain validation  stylesheet
      def get_schematron_processor
        raise "Implement me damn it"
      end

    end


    class UncompiledValidator < BaseValidator

      attr_accessor :schematron_file, :stylesheet, :cache, :name, :phase, :msg_type

      # create a new UnCompiledValidator
      # schematron_file - the base schematron rule set that will be used to create the XSLT stylesheet used to perform the validation
      # stylesheet - this is the stylesheet that will be used on the schematron rules to create the validation stylesheet
      # cache - whether or not to cache the validation stylesheet, if false (default) then it will compute the validation stylesheet each time validate is called
      def initialize(name,schematron_file, stylesheet, cache=true, stylesheet_params={})
        @name = name
        @schematron_file  = schematron_file
        @stylesheet = stylesheet
        @cache = cache
        @stylesheet_params = stylesheet_params
      end


      # get the validation stylesheet returning either the cached instance or creating a new instance
      def get_schematron_processor

        return @schematron_processor if @schematron_processor

        doc   = Nokogiri::XML(File.open(@schematron_file))
        doc.root["defaultPhase"] = (@stylesheet_params["phase"] || "ALL")

        xslt  = Nokogiri::XSLT(File.open(@stylesheet))
        result = xslt.transform(doc)
        #this is stupid but needs to be done to assocaite the xslt file with a dirctory
        result = Nokogiri::XML(result.to_s,@schematron_file)
        processor = Nokogiri::XSLT::Stylesheet.parse_stylesheet_doc(result)
        if cache
          @schematron_processor = processor
        end
        return processor
      end

    end

    # CompileValidator -  Validate based off pre-computed XSL stylesheet
    #
    class CompiledValidator < BaseValidator

      attr_accessor :stylesheet, :name

      # stylesheet -  the precomputed validation stylesheet used to validate the document
      def initialize(name,stylesheet)
        @name = name
        @stylesheet = stylesheet
      end

      # return the cached xsl processor or create a new one and cache it in the instance variable
      def get_schematron_processor

        return @schematron_processor if @schematron_processor
        @schematron_processor =  Nokogiri::XSLT(File.open(@stylesheet))
      end

    end


  end
end
