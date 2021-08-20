# frozen_string_literal: true

class BundleDownload
  include Mongoid::Document

  field :encrypted_umls_password, type: String, default: ''
  field :bundle_year, type: String
end
