# :nocov:
require 'time'
module Cypress
  class ApiMeasureEvaluator
    def initialize(username, password, args = nil)
      @allowable_population_ids = []
      @options = args ? args : {}
      @logger = Rails.logger
      @patient_link_product_test_hash = {}
      @patient_links_task_hash = {}
      @cat3_filter_hash = {}
      @cat1_filter_hash = {}
      @filter_patient_link = nil
      @hqmf_path = @options[:hqmf_path]
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
      Vendor.where(name: /MeasureEvaluationVendor/).destroy_all
      @logger.info 'done'
    end

    def cleanup_hashes
      @patient_link_product_test_hash = {}
      @patient_links_task_hash = {}
      @cat3_filter_hash = {}
      @cat1_filter_hash = {}
      @filter_patient_link = nil
    end

    def parse_hqmf_for_population_ids
      Zip::ZipFile.open(@hqmf_path) do |zipfile|
        zipfile.entries.each do |entry|
          doc = Nokogiri::XML(zipfile.read(entry))
          doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
          doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
          filter_out_populations(doc)
        end
      end
    end

    def filter_out_populations(doc)
      population_names = %w(denominator initialPopulation denominatorExclusions denominatorExceptions numerator
                            measurePopulation measurePopulationExclusions MeasureObservations)
      population_names.each do |population_name|
        population_xpath = %(/cda:QualityMeasureDocument/cda:component/cda:populationCriteriaSection/cda:component
          //cda:id[@extension = '#{population_name}'])
        pop_ids = doc.xpath(population_xpath)
        pop_ids.each do |pop_id|
          @allowable_population_ids << pop_id['root'] if pop_id
        end
      end
    end

    def run_measure_eval(c1_c2, c4)
      parse_hqmf_for_population_ids if @hqmf_path

      # getting measures from bundles is a little convoluted
      bundles = parsed_api_object(call_get_bundles)
      bundles.each do |bundle|
        measures_list = []
        measures_link = extract_link(bundle, 'measures')
        bundle_id = measures_link.split('/')[2]
        measures = parsed_api_object(call_get_measures(measures_link))
        measures.each do |measure|
          measures_list << measure['hqmf_id']
        end

        # create vendor
        vendor_link = create_new_vendor("MeasureEvaluationVendor - #{bundle_id}")
        run_vendor_tests(vendor_link, measures_list.uniq, 'All Measures', false, bundle_id) if c1_c2

        next unless c4
        measures_list.uniq.each do |measure|
          run_vendor_tests(vendor_link, Array.new(1, measure), "Measures - #{measure}", true, bundle_id)
        end
      end
    end

    def run_vendor_tests(vendor_link, measures, product_name, skip_c1_test, bundle_id)
      setup_vendor_test(vendor_link, measures, product_name, skip_c1_test, bundle_id)
      download_patient_test_data
      @patient_links_task_hash.each do |patient_links|
        calcuate_cat_3(patient_links[0].split('/')[2], bundle_id)
        upload_test_execution(extract_test_execution_link(patient_links[1], 'C1'), patient_links[0].split('/')[2], true) unless skip_c1_test
        upload_test_execution(extract_test_execution_link(patient_links[1], 'C2'), patient_links[0].split('/')[2], false, skip_c1_test)
      end
      # sleep(4)
      download_filter_data
      calculate_filtered_cat3(bundle_id)
      upload_c4_test_executions
      cleanup_hashes
    end

    def upload_c4_test_executions
      @cat1_filter_hash.each do |product_test, task|
        upload_test_execution("/tasks/#{task.split('/')[4]}/test_executions", product_test.split('/')[4], true)
      end
      @cat3_filter_hash.each do |product_test, task|
        upload_test_execution("/tasks/#{task.split('/')[4]}/test_executions", product_test.split('/')[4], false)
      end
      File.delete('tmp/filter_patients.zip')
    end

    def setup_vendor_test(vendor_link, measures, product_name, skip_c1_test, bundle_id)
      # create a product for the vendor
      product_link = create_new_product(bundle_id, vendor_link, product_name, measures, skip_c1_test)
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
        sleep(1)
      end
    end

    # This uses Cypress to get the fitered information
    def download_filter_data
      @cat1_filter_hash.each_key do |product_test|
        next unless filter_test_ready?(product_test)
        until File.exist?('tmp/filter_patients.zip')
          @filter_patient_link = extract_link(parsed_api_object(call_get_product_test(product_test)), 'patients') if @filter_patient_link.nil?
          test_patients_already_downloaded = download_test_patients(@filter_patient_link, 'filter_patients') unless test_patients_already_downloaded
          sleep(1)
        end
        parsed_product_test = parsed_api_object(call_get_product_test(product_test))
        Zip::ZipFile.open('tmp/filter_patients.zip') do |zipfile|
          zipfile.entries.each do |entry|
            doc = Nokogiri::XML(zipfile.read(entry))
            doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
            doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
            next unless filter_out_patients(doc, parsed_product_test)
            Zip::ZipFile.open("tmp/#{product_test.split('/')[4]}.zip", Zip::File::CREATE) do |z|
              z.get_output_stream(entry) { |f| f.puts zipfile.read(entry) }
            end
          end
        end
      end
    end

    def filter_test_ready?(product_test)
      count = 0
      while parsed_api_object(call_get_product_test(product_test)).state != 'ready'
        sleep(1)
        count += 1
        # this is only here since c4 tests can't build with unknown payer
        next if count < 20
        @cat1_filter_hash.delete(product_test)
        @cat3_filter_hash.delete(product_test)
        return false
      end
      true
    end

    def calculate_filtered_cat3(bundle_id)
      @cat3_filter_hash.each_key do |product_test|
        calcuate_cat_3(product_test.split('/')[4], bundle_id)
      end
    end

    def filter_out_patients(doc, product_test)
      filters = product_test.filters
      creation_time = product_test.created_at
      return filter_providers(doc, filters) if filters.key?('provider')
      return filter_problems(doc, filters) if filters.key?('problem')
      filter_demographics(doc, filters, creation_time)
    end

    def filter_providers(doc, filters)
      counter = 0
      provider = filters['provider']
      tin_xpath = %(/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/
        cda:id[@root = "2.16.840.1.113883.4.6"]/@extension)
      npi_xpath = %(/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/
        cda:representedOrganization/cda:id[@root = "2.16.840.1.113883.4.2"]/@extension)
      counter += 1 if provider.value?(doc.at_xpath(tin_xpath).value)
      counter += 1 if provider.value?(doc.at_xpath(npi_xpath).value)
      if provider.key?('address') && counter == 2
        address = provider['address']
        address_xpath = %(/cda:ClinicalDocument/cda:documentationOf/cda:serviceEvent/cda:performer/cda:assignedEntity/
          cda:addr/cda:streetAddressLine)
        return true if address.value?(doc.at_xpath(address_xpath).children.text)
      elsif counter == 2
        return true
      end
      false
    end

    def filter_problems(doc, filters)
      problem_array = []
      problems_xpath = %(//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11']
        /cda:value[@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet|//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.13']
        /cda:value[@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet|//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.14']
        /cda:value[@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet|//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.135']
        /cda:value[@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet|//cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.11']
        /cda:value[cda:translation/@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet|
        //cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.13']
        /cda:value[cda:translation/@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet|
        //cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.14']
        /cda:value[cda:translation/@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet|
        //cda:observation[cda:templateId/@root='2.16.840.1.113883.10.20.24.3.135']
        /cda:value[cda:translation/@codeSystem='2.16.840.1.113883.6.96']/@sdtc:valueSet)
      problems = doc.xpath(problems_xpath)
      problems.each do |problem|
        problem_array << problem.value
      end
      return true if problem_array.include? filters['problem']
    end

    def filter_demographics(doc, filters, creation_time)
      counter = 0
      age_filter_holder = nil
      race_xpath = '/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:raceCode/@code'
      gender_xpath = '/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:administrativeGenderCode/@code'
      ethnic_xpath = '/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:ethnicGroupCode/@code'
      payer_xpath = %(/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/
        cda:entry/cda:observation[cda:templateId/@root = '2.16.840.1.113883.10.20.24.3.55']/cda:value/@code)
      payer_value = doc.at_xpath(payer_xpath).value if doc.at_xpath(payer_xpath)
      if filters.key?('age')
        age_filter_holder = filters['age']
        counter += 1 if compare_age(doc, age_filter_holder, creation_time)
        filters.delete('age')
      end
      counter += 1 if filters.value?(doc.at_xpath(race_xpath).value)
      counter += 1 if filters.value?(doc.at_xpath(gender_xpath).value)
      counter += 1 if filters.value?(doc.at_xpath(ethnic_xpath).value)
      counter += 1 if filters.value?(get_payer_name(payer_value))
      filters['age'] = age_filter_holder if age_filter_holder
      return true if counter == 2
    end

    def compare_age(doc, age_filter, creation_time)
      age_xpath = '/cda:ClinicalDocument/cda:recordTarget/cda:patientRole/cda:patient/cda:birthTime/@value'
      patient_birth_time = HealthDataStandards::Util::HL7Helper.timestamp_to_integer(doc.at_xpath(age_xpath).value)
      filter_time = Time.parse(creation_time).to_i
      age_shit = 31_556_952 * age_filter[1]
      if age_filter[0] == 'max'
        # Need to add a year e.g. you are 8 until you are 9.
        # This is currently simplistic, since it doesn't take birth 'time' into consideration
        if filter_time < patient_birth_time + age_shit + 31_556_952
          true
        else
          false
        end
      elsif filter_time > patient_birth_time + age_shit
        true
      else
        false
      end
    end

    def get_payer_name(payer_code)
      case payer_code
      when '1'
        'Medicare'
      when '2'
        'Medicaid'
      when '349'
        'Other'
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

    def create_new_product(bundle_id, vendor_link, product_name, measure_list, skip_c1_test)
      c1_test = skip_c1_test ? '0' : '1'
      jdata = { product: { bundle_id: bundle_id,
                           name: product_name,
                           measure_ids: measure_list,
                           c1_test: c1_test,
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
      file_name = product_test_link.split('/')[2] unless file_name
      resource = RestClient::Resource.new("#{@cypress_host}#{product_test_link}", timeout: 90_000_000,
                                                                                  user: @username,
                                                                                  password: @password)
      begin
        response = resource.get
        if !response.empty?
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

    def upload_test_execution(task_execution_path, product_test_id, is_cat_1, skip_c1_test = nil)
      resource = RestClient::Resource.new("#{@cypress_host}#{task_execution_path}", user: @username,
                                                                                    password: @password,
                                                                                    headers: { :accept => :json })
      if is_cat_1
        resource.post(results: File.new("tmp/#{product_test_id}.zip"))
        File.delete("tmp/#{product_test_id}.zip")
      else
        resource.post(results: File.new("tmp/#{product_test_id}.xml"))
        verify_population_ids(product_test_id) if @hqmf_path
        File.delete("tmp/#{product_test_id}.xml")
        File.delete("tmp/#{product_test_id}.zip") if skip_c1_test
      end
    end

    def verify_population_ids(product_test_id)
      doc = Nokogiri::XML(File.new("tmp/#{product_test_id}.xml"))
      doc.root.add_namespace_definition('cda', 'urn:hl7-org:v3')
      doc.root.add_namespace_definition('sdtc', 'urn:hl7-org:sdtc')
      population_xpath = %(/cda:ClinicalDocument/cda:component/cda:structuredBody/cda:component/cda:section/cda:entry/cda:organizer
        /cda:component/cda:observation/cda:reference/cda:externalObservation/cda:id)
      pop_ids = doc.xpath(population_xpath)
      pop_ids.each do |pop_id|
        @logger.error "#{pop_id['root']} should not be in measure check bonnie bundler" unless @allowable_population_ids.include? pop_id['root']
      end
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
