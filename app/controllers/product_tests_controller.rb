# frozen_string_literal: true

class ProductTestsController < ApplicationController
  include Api::Controller

  before_action :set_product, except: %i[show patients measure html_patients update]
  before_action :set_product_test, only: %i[show update destroy patients measure html_patients]
  before_action :authorize_vendor

  def measure; end

  def update; end

  def destroy; end

  def index
    @product_tests = @product.product_tests
    respond_with(@product_tests.to_a)
  end

  def show
    respond_with(@product_test)
  end

  # always respond with a .qrda.zip file of qrda category I documents
  def patients
    file_name = "#{@product_test.cms_id}_#{@product_test.id}.qrda.zip".tr(' ', '_')
    send_data @product_test.patient_archive.read, type: 'application/zip', disposition: 'attachment', filename: file_name
  end

  def html_patients
    file_name = "#{@product_test.cms_id}_#{@product_test.id}.html.zip".tr(' ', '_')
    send_data @product_test.html_archive.read, type: 'application/zip', disposition: 'attachment', filename: file_name
  end

  private

  def authorize_vendor
    vendor = @product ? @product.vendor : @product_test.product.vendor
    authorize_request(vendor, read: ['patients'])
  end
end
