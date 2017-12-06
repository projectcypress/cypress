require 'test_helper'
require 'fileutils'

class CreateDownloadZipTest < ActiveSupport::TestCase

  setup do
    collection_fixtures('records', 'bundles', 'vendors', 'products', 'product_tests', 'tasks', 'test_executions')

  end

  test 'Should create appropriate html' do

    product2014 = Product.where('cert_edition'=>'2014').first
    product2015C1 = Product.where('cert_edition'=>'2015', 'c2_test'=>false).first
    product2015C2 = Product.where('cert_edition'=>'2015', 'c2_test'=>true).first
    # byebug

    [product2014, product2015C1, product2015C2].each do |product|
      # next if(!product)
      # product_test = product.product_tests.build({ name: "mtest #{rand}", measure_ids: ['8A4D92B2-35FB-4AA7-0136-5A26000D30BD'] }, MeasureTest)

      pt = product.product_tests.build({ name: 'mtest', measure_ids: ['8A4D92B2-397A-48D2-0139-C648B33D5582'],
                                         bundle_id: '4fdb62e01d41c820f6000001' }, MeasureTest)
      pt.create_tasks
      pt.archive_records if pt.patient_archive.path.nil?
      pt.save!
      file = Cypress::CreateTotalTestZip.create_total_test_zip(product, nil, nil, 'qrda')

      Zip::File.open(file) do |zip_file|
        if (product.cert_edition == '2015' && product.c2_test)
          assert_empty zip_file.glob('*.html.zip')
        else
          assert_not_empty zip_file.glob('*.html.zip')
        end
      end
    end
  end

end
