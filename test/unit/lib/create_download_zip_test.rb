require 'test_helper'
require 'fileutils'

class CreateDownloadZipTest < ActiveSupport::TestCase
  test 'Should create appropriate html' do
    product_2015_c1 = FactoryBot.create(:product_no_c2)
    product_2015_c2 = FactoryBot.create(:product_static_bundle)

    [product_2015_c1, product_2015_c2].each do |product|
      pt = product.product_tests.build({ name: 'mtest', measure_ids: product.measure_ids }, MeasureTest)
      pt.save
      pt.generate_patients
      pt.create_tasks
      pt.archive_patients if pt.patient_archive.path.nil?
      pt.save!
      file = Cypress::CreateTotalTestZip.create_total_test_zip(product, nil, nil, 'qrda')

      Zip::File.open(file) do |zip_file|
        if product.c2_test
          assert_empty zip_file.glob('*.html.zip')
        else
          assert_not_empty zip_file.glob('*.html.zip')
        end
      end
    end
  end

  test 'Should create appropriate zip for cvu' do
    product_cvu = FactoryBot.create(:product_static_bundle)

    pt = product_cvu.product_tests.build({ name: 'mtest', measure_ids: product_cvu.measure_ids }, MultiMeasureTest)
    pt.save
    pt.generate_patients
    pt.create_tasks
    pt.archive_patients if pt.patient_archive.path.nil?
    pt.save!
    file = Cypress::CreateTotalTestZip.create_total_test_zip(product_cvu, nil, nil, 'qrda')

    Zip::File.open(file) do |zip_file|
      assert_not_empty zip_file.glob("#{pt.name}_#{pt.id}.qrda.zip")
    end
  end
end
