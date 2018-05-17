require 'test_helper'
require 'fileutils'

class CreateDownloadZipTest < ActiveSupport::TestCase
  test 'Should create appropriate html' do
    product2014 = FactoryBot.create(:product_2014)
    product_2015_c1 = FactoryBot.create(:product_no_c2)
    product_2015_c2 = FactoryBot.create(:product_static_bundle)

    [product2014, product_2015_c1, product_2015_c2].each do |product|
      pt = product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-397A-48D2-0139-C648B33D5582'],
                                         bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
      pt.create_tasks
      pt.archive_records if pt.patient_archive.path.nil?
      pt.save!
      file = Cypress::CreateTotalTestZip.create_total_test_zip(product, nil, nil, 'qrda')

      Zip::File.open(file) do |zip_file|
        if product.cert_edition == '2015' && product.c2_test
          assert_empty zip_file.glob('*.html.zip')
        else
          assert_not_empty zip_file.glob('*.html.zip')
        end
      end
    end
  end
end
