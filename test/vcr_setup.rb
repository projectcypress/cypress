require 'vcr'
require 'webmock/minitest'

# VCR records HTTP interactions to cassettes that can be replayed during unit tests
# allowing for faster, more predictible web interactions
VCR.configure do |c|
  # This is where the various cassettes will be recorded to
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.allow_http_connections_when_no_cassette = true

  # To avoid storing plain text VSAC credentials or requiring the VSAC credentials
  # be provided at every run of the rake tests, provide the VSAC_USERNAME and VSAC_PASSWORD
  # whenever you need to record a cassette that requires valid credentials
  ENV['VSAC_USERNAME'] = 'vcrtest' unless ENV['VSAC_USERNAME']
  ENV['VSAC_PASSWORD'] = 'vcrpass' unless ENV['VSAC_PASSWORD']

  # Ensure plain text passwords do not show up during logging
  c.filter_sensitive_data('<VSAC_USERNAME>') { ENV['VSAC_USERNAME'] }
  c.filter_sensitive_data('<VSAC_PASSWORD>') { URI.encode_www_form_component(ENV['VSAC_PASSWORD']) }
  c.default_cassette_options = { record: :once }
end
