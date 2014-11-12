module Cypress
  class PophealthRoundtrip
    def initialize(args = nil)
      @options = args
    end

    # Removes cached data and any prior tests from popHealth and cypress
    def cleanup(args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]

      #calls the 'remove patients' and 'remove cache' functions on the popHealth instance being worked with
      `curl -X DELETE -u #{pophealth_user}:#{pophealth_password} #{url}/admin/remove_patients`
      `curl -X DELETE -u #{pophealth_user}:#{pophealth_password} #{url}/admin/remove_caches`

      ProductTest.where({name: "popHealthRoundtripTest"}).each do |test|
        Result.where({"value.test_id" => test.id}).destroy_all
        # TODO uncomment this when we use the new QME; for the moment Quality Reports aren't cached, but will be in Cypress 2.5
        # QME::QualityReport.where({"test_id" => test.id}).destroy_all
        test.destroy
      end

      Vendor.where({name: "popHealthRoundtripVendor"}).destroy_all
      Product.where({name: "popHealthRoundtripProduct"}).destroy_all
    end

    # Generates a test based on the measure_ids hash passed in, then creates the downloadable patient zip
    # NOTE: doesn't currently check to make sure the test type matches the measures passed in (I.E. Calculated for ep, Inpatient for eh)
    # RETURNS: A handle to the zip file
    def generate_cat1_zip(args = nil)
      opts = args ? @options.merge(args) : @options
      user = opts[:cypress_user] ? User.where({email: opts[:cypress_user]}).first : User.first
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first
      test_type = opts[:test_type] ? opts[:test_type] : "CalculatedProductTest"

      vendor = Vendor.find_or_create_by({name: "popHealthRoundtripVendor"})
      product = Product.find_or_create_by({name: "popHealthRoundtripProduct", vendor_id: vendor.id})
      product.users << user
      product.save
      product_test = test_type.camelize.constantize.new({name: "popHealthRoundtripTest",
                                                         bundle: bundle.id,
                                                         effective_date: bundle.effective_date,
                                                         product: product,
                                                         measure_ids: opts[:measure_ids]})
      product_test.user = user
      product_test.save
      Cypress::CreateDownloadZip.create_test_zip(product_test.id, "qrda")
    end

    #Uploads the cat1 zip passed in to the pophealth instance
    def upload_cat1_zip(zip, args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]

      `curl -X PUT -u #{pophealth_user}:#{pophealth_password} -F file=@#{zip.path} #{url}/admin/upload_patients`
    end

    # Calls the query API creat function for the respective measures, so they can be calculated when we download the cat 3
    # RETURNS: The MongoDB IDs of
    def kickoff_calculation(args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first

      opts[:measure_ids].collect do |measure_id|
        HealthDataStandards::CQM::Measure.where({hqmf_id: measure_id}).collect do |measure|
          JSON.parse(`curl -X POST -u #{pophealth_user}:#{pophealth_password}
                      --header "Content-Type:application/x-www-form-urlencoded"
                      --data "measure_id=#{measure.hqmf_id}&sub_id=#{measure.sub_id}effective_date=#{bundle.effective_date}"
                      #{url}/api/queries`)['ids']
        end
      end
    end

    # Waits for all the measure query calculations to complete, then grabs the cat 3 XML for the requested measures from popHealth
    # RETURNS: a string containing the contents of the cat 3 XML request
    def get_pophealth_xml(ids, args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first

      # As it turns out, we need to wait for the queries in popHealth to complete before we grab the XML, or else we just get an error page.
      # Also, this lets us grab the measure HQMF IDs (in the mids array)
      complete = false
      mids = []
      while (!complete)
        sleep(2)
        mids = []
        complete = ids.inject(true) do |memo, id|
          res = JSON.parse(`curl -X GET -u #{pophealth_user}:#{pophealth_password} #{url}/api/queries/#{id}`)
          mids << res['measure_id']
          res['status']['state'] == "completed" && memo
        end
      end

      `curl -X GET -u #{pophealth_user}:#{pophealth_password} --header "Content-Type:application/x-www-form-urlencoded" --data "effective_date=#{bundle.effective_date}&#{measure_ids(mids)}" #{url}/api/reports/qrda_cat3.xml`
    end

    # Uploads the cat 3 XML data from popHealth to our test in cypress
    def upload_cypress_xml(xml, args = nil)
      opts = args ? @options.merge(args) : @options
      cypress_url = opts[:cypress_url]
      user = opts[:cypress_user] ? User.where({email: opts[:cypress_user]}).first : User.first
      cypress_password = opts[:cypress_password]
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first
      product_test = ProductTest.where({name: "popHealthRoundtripTest"}).first

      # Generate a temporary file that acts just like a normal file, but is given a unique name in the './tmp' directory
      tmp = Tempfile.new(['qrda_upload', '.xml'], './tmp')
      tmp.write(xml)
      product_test.execute({results: tmp})

    end

    # Runs through all of the tasks needed to roundtrip something in Cypress/popHealth, including cleaning both systems beforehand
    def zip_roundtrip(args = nil)
      cleanup(args)
      zip = generate_cat1_zip(args)
      upload_cat1_zip(zip, args)
      ids = kickoff_calculation(args)
      xml = get_pophealth_xml(ids, args)
      upload_cypress_xml(xml, args)
    end

    private

    # Turns out to send arrays of objects in a URL, you need to use the format below,
    # where you have the param name followed by brackets, followed by one of the values for the array, repeated for each value
    def measure_ids(ids)
      "measure_ids[]=" + ids.join("&measure_ids[]=")
    end

  end
end
