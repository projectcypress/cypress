# :nocov:
module Cypress
  class ApiMeasureEvaluator
    def initialize(username, password, args = nil)
      @options = args ? args : {}
      @logger = Rails.logger
      @patient_link_product_test_hash = {}
      @patient_links_task_hash = {}
      @cat3_filter_hash = {}
      @cat1_filter_hash = {}
      @filter_patient_link = nil
      @c4_cat1_tasks = []
      @c4_cat3_tasks = []
      @cypress_host = if @options[:cypress_host]
                        @options[:cypress_host]
                      else
                        'http://localhost:3000'
                      end
      @username = username
      @password = password
    end

    def cleanup(*)
      @logger.info 'Cleaning database...'
      Vendor.where(name: 'MeasureEvaluationVendor').destroy_all
      @logger.info 'done'
    end

    def setup_vendor_tests
      measures_list = []
      # getting measures from bundles is a little convoluted
      bundles = parsed_api_object(call_get_bundles)
      measures_link = extract_link(bundles[0], 'measures')
      @bundle_id = measures_link.split('/')[2]
      measures = parsed_api_object(call_get_measures(measures_link))

      measures.each do |measure|
        measures_list << measure['hqmf_id']
      end

      # create vendor
      vendor_link = create_new_vendor('MeasureEvaluationVendor')
      # create a product for the vendor
      product_link = create_new_product(@bundle_id, vendor_link, 'api_product_1', measures_list.uniq[0,1])
      # get the product create
      single_product = call_get_product(product_link)
      # get the link to the product's product tests
      product_tests_link = extract_link(parsed_api_object(single_product), 'product_tests')
      # get all of the product tests for the product
      product_tests = parsed_api_object(call_get_product_tests(product_tests_link))

      product_tests.each do |product_test|
        populate_patient_download_hashes(product_test)
      end
    end

    def populate_patient_download_hashes(product_test)
      # get link for product test tasks
      if product_test.type == 'measure'
        product_test_tasks_link = extract_link(product_test, 'tasks')
        # get product tasks objects
        product_test_tasks = call_get_product_test_tasks(product_test_tasks_link)
        # get link for patient download for product
        patient_download_link = extract_link(product_test, 'patients')
        # hash of patient list with product test tasks - this will be used for upload
        @patient_links_task_hash[patient_download_link] = parsed_api_object(product_test_tasks)
        # hash of patient list with product tests - this is used to see if the patiets are ready
        @patient_link_product_test_hash[patient_download_link] = extract_link(product_test, 'self')
      elsif product_test.type == 'filter'
        @filter_patient_link = extract_link(product_test, 'patients') if @filter_patient_link == nil
        product_test_tasks_link = extract_link(product_test, 'tasks')
        # get product tasks objects
        product_test_tasks = parsed_api_object(call_get_product_test_tasks(product_test_tasks_link))
        product_test_tasks.each do |product_test_task|
          task_link = extract_link(product_test_task, 'self')
          if product_test_task.type == 'Ct1Filter'
            @cat1_filter_hash[extract_link(product_test, 'self')] = task_link
          else 
            @cat3_filter_hash[extract_link(product_test, 'self')] = task_link
          end
        end
      end
    end

    def download_patient_test_data
      # array of all patient download links
      not_dowloaded_test_patients = @patient_links_task_hash.keys

      # run until all patient links have been downloaded
      until not_dowloaded_test_patients.empty?
        patient_download_link = not_dowloaded_test_patients.pop
        pt = parsed_api_object(call_get_product_test(@patient_link_product_test_hash[patient_download_link]))
        # if patient deck is ready, download - add download link back to array if not ready and shuffle
        # note, patient download link needs to get rescued...sometimes test is ready before zip is
        if pt.state == 'ready'
          unless download_test_patients(patient_download_link)
            not_dowloaded_test_patients << patient_download_link
            not_dowloaded_test_patients.shuffle!
          end
        else
          not_dowloaded_test_patients << patient_download_link
          not_dowloaded_test_patients.shuffle!
        end
      end
    end

    # This uses Cypress to get the fitered information
    def download_filter_data
      download_test_patients(@filter_patient_link,'filter_patients')
      @cat1_filter_hash.each do |product_test, task|
        pt_filters = parsed_api_object(call_get_product_test(product_test))
        binding.pry
      #  task_id = link.split('/').last
      #  if type == 'Ct1Filter'
      #    File.open("tmp/#{task_id}.zip", 'wb') do |output|
      #      output.write(Task.find(task_id).good_results)
      #    end
      #    @c4_cat1_tasks << task_id
      #  elsif type == 'Ct3Filter'
      #    File.open("tmp/#{task_id}.xml", 'wb') do |output|
      #      output.write(Task.find(task_id).good_results)
      #    end
      #    @c4_cat3_tasks << task_id
      #  end
      end
    end

    def filter_out_patients(doc, filters)
      race = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode/@code').value
      gender = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode/@code').value
      ethnicity = doc.at_xpath('/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:ethnicGroupCode/@code').value
      payer = doc.at_xpath("/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.55']/cda:value/@code").value
      tin = doc.at_xpath('/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:id[@root = "2.16.840.1.113883.4.6"]/@extension').value
      npi = doc.at_xpath('/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:representedOrganization/cda:id[@root = "2.16.840.1.113883.4.2"]/@extension').value
      street_address = doc.at_xpath('/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/cda:addr/cda:streetAddressLine').children.text
      problems = doc.at_xpath("//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11']/cda:value/@sdtc:valueSet")
      false
    end

    def run_measure_eval
      setup_vendor_tests
      download_patient_test_data      
      @patient_links_task_hash.each do |patient_links|
        upload_c1_test_execution(extract_test_execution_link(patient_links[1], 'C1'), patient_links[0].split('/')[2])
        calcuate_cat_3(patient_links[0].split('/')[2], @bundle_id)
        upload_c2_test_execution(extract_test_execution_link(patient_links[1], 'C2'), patient_links[0].split('/')[2])
      end
      sleep(2)
      download_filter_data
      @c4_cat1_tasks.each do |c4_cat1_task|
        Zip::ZipFile.open("tmp/#{c4_cat1_task}.zip") do |zipfile|
          zipfile.entries.each do |entry|
            doc = Nokogiri::XML(zipfile.read(entry))
            doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
            doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
            binding.pry
            
            binding.pry
          end
        end
        upload_c4_test_execution(c4_cat1_task, true)
      end
      @c4_cat3_tasks.each do |c4_cat3_task|
        upload_c4_test_execution(c4_cat3_task, false)
      end
    end

    def call_get_bundles
      RestClient::Request.execute(:method => :get,
                                  :url => "#{@cypress_host}/bundles",
                                  :user => @username,
                                  :password => @password,
                                  :headers => { :accept => :json })
    end

    def call_get_measures(measures_link)
      RestClient::Request.execute(:method => :get,
                                  :url => "#{@cypress_host}#{measures_link}",
                                  :user => @username,
                                  :password => @password,
                                  :headers => { :accept => :json })
    end

    def create_new_vendor(vendor_name)
      jdata = { vendor: { name: vendor_name } }
      RestClient::Request.execute(:method => :post,
                                  :url => "#{@cypress_host}/vendors",
                                  :user => @username,
                                  :password => @password,
                                  :payload => jdata,
                                  :headers => { :accept => :json, :content_type => :json }).headers[:location]
    end

    def create_new_product(bundle_id, vendor_link, product_name, measure_list)
      jdata = { product: { bundle_id: bundle_id,
                           name: product_name,
                           measure_ids: measure_list,
                           c1_test: '1',
                           c2_test: '1',
                           c3_test: '1',
                           c4_test: '1',
                           duplicate_records: '0',
                           randomize_records: '0' } }
      RestClient::Request.execute(:method => :post,
                                  :timeout => 90_000_000,
                                  :url => "#{vendor_link}/products",
                                  :user => @username,
                                  :password => @password,
                                  :payload => jdata,
                                  :headers => { :accept => :json, :content_type => :json }).headers[:location]
    end

    def call_get_product(vendor_product_link)
      RestClient::Request.execute(:method => :get,
                                  :url => vendor_product_link,
                                  :user => @username,
                                  :password => @password,
                                  :headers => { :accept => :json })
    end

    def call_get_product_tests(product_tests_link)
      RestClient::Request.execute(:method => :get,
                                  :url => "#{@cypress_host}#{product_tests_link}",
                                  :user => @username,
                                  :password => @password,
                                  :headers => { :accept => :json })
    end

    def call_get_product_test(product_test_link)
      RestClient::Request.execute(:method => :get,
                                  :url => "#{@cypress_host}#{product_test_link}",
                                  :user => @username,
                                  :password => @password,
                                  :headers => { :accept => :json })
    end

    def call_get_product_test_tasks(product_test_tasks_link)
      RestClient::Request.execute(:method => :get,
                                  :url => "#{@cypress_host}#{product_test_tasks_link}",
                                  :user => @username,
                                  :password => @password,
                                  :headers => { :accept => :json })
    end

    def download_test_patients(product_test_link, file_name = nil)
      file_name = product_test_link.split('/')[2] if !file_name
      resource = RestClient::Resource.new("#{@cypress_host}#{product_test_link}", timeout: 90_000_000,
                                                                                  user: @username,
                                                                                  password: @password)
      begin
        response = resource.get
        if response.size > 0
          File.open("tmp/#{file_name}.zip", 'wb') do |output|
            output.write(response)
          end
          true
        else
          false
        end
      rescue
        false
      end
    end

    def upload_c4_test_execution(task_id, is_cat_1)
      resource = RestClient::Resource.new("#{@cypress_host}/tasks/#{task_id}/test_executions", user: @username,
                                                                                               password: @password,
                                                                                               headers: { :accept => :json })
      if is_cat_1
        resource.post(results: File.new("tmp/#{task_id}.zip"))
        File.delete("tmp/#{task_id}.zip")
      else
        resource.post(results: File.new("tmp/#{task_id}.xml"))
        File.delete("tmp/#{task_id}.xml")
      end
    end

    def upload_c1_test_execution(task_id, product_test_id)
      resource = RestClient::Resource.new("#{@cypress_host}#{task_id}", user: @username,
                                                                        password: @password,
                                                                        headers: { :accept => :json })
      resource.post(results: File.new("tmp/#{product_test_id}.zip"))
    end

    def upload_c2_test_execution(task_id, product_test_id)
      resource = RestClient::Resource.new("#{@cypress_host}#{task_id}", user: @username,
                                                                        password: @password,
                                                                        headers: { :accept => :json })
      resource.post(results: File.new("tmp/#{product_test_id}.xml"))
      File.delete("tmp/#{product_test_id}.xml")
      File.delete("tmp/#{product_test_id}.zip")
    end

    def download_report(vendor_product_link)
      RestClient::Request.execute(:method => :get,
                                  :url => "#{vendor_product_link}/report",
                                  :user => @username,
                                  :password => @password)
    end

    def extract_link(object_with_links, type_of_link)
      object_with_links = object_with_links.first if object_with_links.is_a?(Array)
      if object_with_links['links']
        object_with_links['links'].each do |link|
          return link['href'] if link['rel'] == type_of_link
        end
      end
    end

    def extract_test_execution_link(product_test_tasks, task_type)
      product_test_tasks.each do |task|
        return extract_link(task, 'executions') if task['type'] == task_type
      end
    end

    def parsed_api_object(unparsed_string)
      JSON.parse(unparsed_string)
    end

    def calcuate_cat_3(product_test_id, bundle_id)
      pt = ProductTest.find(product_test_id)
      c3c = Cypress::Cat3Calculator.new(pt.measure_ids, Bundle.find(bundle_id))
      c3c.import_cat1_zip(File.new("tmp/#{product_test_id}.zip"))
      xml = c3c.generate_cat3
      File.write("tmp/#{product_test_id}.xml", xml)
    end
  end
end
