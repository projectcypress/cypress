module Cypress
  class CreateTotalTestZip
    def self.create_total_test_zip(product, criteria_list, filtering_list, format = 'qrda')
      file = Tempfile.new("all-patients-#{Time.now.to_i}")
      Zip::ZipOutputStream.open(file.path) do |z|
        add_measure_zips(z, product.product_tests.measure_tests, format)
        add_checklist_zips(z, product.product_tests.checklist_tests, criteria_list)
        add_filtering_zips(z, product.product_tests.filtering_tests, format, filtering_list) unless product.product_tests.filtering_tests.empty?
        add_html_files(z, product.product_tests) unless product.c2_test
      end
      file
    end

    def self.add_measure_zips(z, measure_tests, format)
      measure_tests.each do |pt|
        CreateDownloadZip.add_file_to_zip(z, "#{pt.cms_id}_#{pt.id}.#{format}.zip".tr(' ', '_'), pt.patient_archive.read)
      end
    end

    def self.add_checklist_zips(z, checklist_tests, criteria_list)
      checklist_tests.each do |pt|
        p = pt.product
        file = CreateDownloadZip.create_c1_criteria_zip(p.product_tests.checklist_tests.first, criteria_list).read
        CreateDownloadZip.add_file_to_zip(z, "checklisttest_#{p.name}_#{p.id}_c1_checklist_criteria.zip".tr(' ', '_'), file)
      end
    end

    def self.add_filtering_zips(z, filtering_tests, format, filtering_list)
      pt = filtering_tests.first
      CreateDownloadZip.add_file_to_zip(z, "filteringtest_#{pt.cms_id}_#{pt.id}.#{format}.zip".tr(' ', '_'), pt.patient_archive.read)
      unless pt.product.c2_test
        CreateDownloadZip.add_file_to_zip(z, "filteringtest_#{pt.cms_id}_#{pt.id}.html.zip".tr(' ', '_'),
                                          pt.html_archive.read)
      end
      CreateDownloadZip.add_file_to_zip(z, 'filtering_criteria.html', filtering_list)
    end

    def self.add_html_files(z, tests)
      tests.each do |pt|
        unless pt[:html_archive].nil? || (pt.is_a? FilteringTest)
          CreateDownloadZip.add_file_to_zip(z, "#{pt.cms_id}_#{pt.id}.html.zip".tr(' ', '_'),
                                            pt.html_archive.read)
        end
      end
    end
  end
end
