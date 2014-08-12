module Cypress
  class PophealthRoundtrip
    def initialize(args = nil)
      @options = args
    end

    def cleanup(args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]

      puts `curl -X DELETE -u #{pophealth_user}:#{pophealth_password} #{url}/admin/remove_patients`
      puts `curl -X DELETE -u #{pophealth_user}:#{pophealth_password} #{url}/admin/remove_caches`

      ProductTest.where({name: "popHealthRoundtripTest"}).each do |test|
        Result.where({"value.test_id" => test.id}).destroy_all
        # TODO uncomment this when we use the new QME
        # QME::QualityReport.where({"test_id" => test.id}).destroy_all
        test.destroy
      end

      Vendor.where({name: "popHealthRoundtripVendor"}).destroy_all
      Product.where({name: "popHealthRoundtripProduct"}).destroy_all
    end

    def generate_cat1_zip(args = nil)
      opts = args ? @options.merge(args) : @options
      user = opts[:cypress_user] ? User.where({email: opts[:cypress_user]}).first : User.first
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first
      test_type = opts[:test_type] ? opts[:test_type] : "CalculatedProductTest"

      vendor = Vendor.find_or_create_by({name: "popHealthRoundtripVendor"})
      product = Product.find_or_create_by({name: "popHealthRoundtripProduct", vendor_id: vendor.id, user_id: user.id})
      product_test = test_type.camelize.constantize.new({name: "popHealthRoundtripTest", bundle: bundle.id, effective_date: bundle.effective_date, user_id: user.id, product_id: product.id, measure_ids: opts[:measure_ids]})
      product_test.save
      Cypress::CreateDownloadZip.create_test_zip(product_test.id, "qrda")
    end

    def upload_cat1_zip(zip, args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]

      puts `curl -X PUT -u #{pophealth_user}:#{pophealth_password} -F file=@#{zip.path} #{url}/admin/upload_patients`
    end

    def kickoff_calculation(args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first

      opts[:measure_ids].collect do |measure_id|
        ret = JSON.parse(`curl -X POST -u #{pophealth_user}:#{pophealth_password} --header "Content-Type:application/x-www-form-urlencoded" --data "measure_id=#{measure_id}&effective_date=#{bundle.effective_date}" #{url}/api/queries`)
        ret["_id"]
      end
    end

    def get_pophealth_xml(ids, args = nil)
      opts = args ? @options.merge(args) : @options
      url = opts[:pophealth_url]
      pophealth_user = opts[:pophealth_user]
      pophealth_password = opts[:pophealth_password]
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first

      complete = false
      mids = []
      while (!complete)
        sleep(1)
        mids = []
        complete = ids.inject(true) do |memo, id|
          res = JSON.parse(`curl -X GET -u #{pophealth_user}:#{pophealth_password} #{url}/api/queries/#{id}`)
          mids << res['measure_id']
          res['status']['state'] == "completed" && memo
        end
      end

      `curl -X GET -u #{pophealth_user}:#{pophealth_password} --header "Content-Type:application/x-www-form-urlencoded" --data "effective_date=#{bundle.effective_date}&#{measure_ids(mids)}" #{url}/api/reports/qrda_cat3.xml`
    end

    def upload_cypress_xml(xml, args = nil)
      opts = args ? @options.merge(args) : @options
      cypress_url = opts[:cypress_url]
      user = opts[:cypress_user] ? User.where({email: opts[:cypress_user]}).first : User.first
      cypress_password = opts[:cypress_password]
      bundle = opts[:version] ? Bundle.where({version: opts[:version]}).first : Bundle.first
      product_test = ProductTest.where({name: "popHealthRoundtripTest"}).first

      tmp = Tempfile.new(['qrda_upload', '.xml'], './tmp')
      tmp.write(xml)
      qrda = Rack::Test::UploadedFile.new(tmp.path, "application/xml")
      product_test.execute({results: tmp})

    end

    def create_and_upload_zip(args = nil)
      cleanup(args)
      zip = generate_cat1_zip(args)
      upload_cat1_zip(zip, args)
      ids = kickoff_calculation(args)
      xml = get_pophealth_xml(ids, args)
      upload_cypress_xml(xml, args)
    end

    private

    def measure_ids(ids)
      "measure_ids[]=" + ids.join("&measure_ids[]=")
    end

  end
end
