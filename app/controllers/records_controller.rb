class RecordsController < ApplicationController
  # requires params[:id] to be id of a product
  def download_full_test_deck
    product = Product.find(params[:id])
    file = Cypress::CreateDownloadZip.create_total_test_zip(product)
    send_data file.read, type: 'application/zip', disposition: 'attachment', filename: "Full_Test_Deck_#{product.id}.zip"
  end
end
