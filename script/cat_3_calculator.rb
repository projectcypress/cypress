# :nocov:
require 'mongoid'
require 'health-data-standards'
require 'quality-measure-engine'
require 'optparse'

def generate_oid_dictionary(measure, bundle)
  valuesets = bundle.value_sets.in(oid: measure.oids)
  js = {}
  valuesets.each do |vs|
    js[vs.oid] ||= {}
    vs.concepts.each do |con|
      name = con.code_system_name
      js[vs.oid][name] ||= []
      js[vs.oid][name] << con.code.downcase unless js[vs.oid][name].index(con.code.downcase)
    end
  end

  js.to_json
end

# Generates a QRDA Cat 3 for a particular set of measures
def generate_cat3(measure_ids, effective_date)
  exporter = HealthDataStandards::Export::Cat3.new
  end_date = Time.at(effective_date.to_i + 59).in_time_zone
  filter = measure_ids == ['all'] ? {} : { :hqmf_id.in => measure_ids, :bundle_id => Bundle.default.id }
  exporter.export(HealthDataStandards::CQM::Measure.top_level.where(filter),
                  generate_header,
                  effective_date.to_i,
                  end_date.years_ago(1) + 1,
                  end_date, nil)
end

# Generates the QRDA/CDA header, using the header info above
def generate_header(provider = nil)
  cda_header = { identifier: { root: 'CypressRoot', extension: 'CypressExtension' },
                 authors:       [{ ids: [{ root: 'authorRoot', extension: 'authorExtension' }],
                                   device: { name: 'deviceName', model: 'deviceModel' },
                                   addresses: [], telecoms: [], time: nil,
                                   organization: { ids: [{ root: 'authorsOrganizationRoot', extension: 'authorsOrganizationExt' }], name: '' } }],
                 custodian: { ids: [{ root: 'custodianRoot', extension: 'custodianExt' }],
                              person: { given: '', family: '' }, organization: { ids: [{ root: 'custodianOrganizationRoot',
                                                                                         extension: 'custodianOrganizationExt' }], name: '' } },
                 legal_authenticator: { ids: [{ root: 'legalAuthenticatorRoot', extension: 'legalAuthenticatorExt' }], addresses: [],
                                        telecoms: [], time: nil,
                                        person: { given: nil, family: nil },
                                        organization: { ids: [{ root: 'legalAuthenticatorOrgRoot', extension: 'legalAuthenticatorOrgExt' }],
                                                        name: '' } } }

  header = Qrda::Header.new(cda_header)

  header.identifier.root = UUID.generate
  header.authors.each { |a| a.time = Time.current }
  header.legal_authenticator.time = Time.current
  header.performers << provider

  header
end

def capture_output
  previous_stdout = $stdout
  $stdout = StringIO.new
  previous_stderr = $stderr
  $stderr = StringIO.new
  yield
  $stdout.string
ensure
  $stderr = previous_stderr
  $stdout = previous_stdout
end

measure_ids = []
zipfile = ''
bundle = nil
_captured_output = capture_output do
  OptionParser.new do |opts|
    opts.on('-m', '--measure MEASURE', 'A measure HQMF id to test') do |mes|
      measure_ids << mes
    end

    opts.on('-z', '--zipfile ZIPFILE', 'A zipfile to import') do |z|
      zipfile = z
    end
  end.parse!

  Mongoid.load!('config/mongoid.yml', :measure_eval)

  if Bundle.first.nil?
    options = { delete_existing: true,
                type: nil,
                update_measures: true,
                exclude_results: true }
    bundle_path = 'bundles/bundle-latest.zip'
    bundle = File.open(bundle_path)
    importer = HealthDataStandards::Import::Bundle::Importer
    importer.import(bundle, options)
    ::Mongoid::Tasks::Database.create_indexes
  end

  zipfile = File.new(zipfile)

  Record.destroy_all
  QME::QualityReport.destroy_all
  QME::PatientCache.destroy_all

  HealthDataStandards::Import::BulkRecordImporter.import_archive(zipfile)
  bundle = Bundle.first

  measure_ids.each do |id|
    measures = HealthDataStandards::CQM::Measure.where(hqmf_id: id)
    measures.each do |m|
      dictionary = generate_oid_dictionary(m, bundle)
      qr = QME::QualityReport.find_or_create(m.hqmf_id, m.sub_id, effective_date: bundle.effective_date,
                                                                  test_id: nil,
                                                                  filters: nil,
                                                                  enable_logging: false,
                                                                  enable_rationale: false)
      qr.calculate({ bundle_id: bundle.id, oid_dictionary: dictionary }, false)
    end
  end
end

print generate_cat3(measure_ids, bundle.effective_date)
# :nocov:
