require 'mongoid'
require 'csv'
require 'byebug'

Mongoid.load!('config/mongoid.yml', :development)
@valuesets = ValueSet.all
measures = CQM::Measure.all

# Drupal loading section
require 'rest-client'
require 'digest'
require 'date'

@options = {}

# Parse the arguments file (json), if passed:
if ARGV[0]
  options_file = ARGV[0].chomp
  File.open(options_file, 'r') { |f| @options = JSON.parse(f.read) }
  puts @options
end

# Only ask for the username if it wasn't supplied
unless @options['username']
  print 'Drupal Username: '
  @options['username'] = STDIN.gets.chomp
end

# # Don't use a password from the file, because there's no way that's secure
# print 'Drupal Password: '
@options['password'] = STDIN.noecho(&:gets).chomp

# Only ask for the data element version if it wasn't supplied
unless @options['data_element_version']
  print "\nData Element Version (e.g. 0.1.3): "
  @options['data_element_version'] = STDIN.gets.chomp
end

# Only ask for the base url if it wasn't supplied
unless @options['base_url']
  print 'Drupal base url (e.g. https://ecqi.healthit.gov): '
  @options['base_url'] = STDIN.gets.chomp
end

# Headers for execute_request (required by JSON:API)
@base_opts = {
  'Content-Type': 'application/vnd.api+json',
  'Accept': 'application/vnd.api+json'
}

@data_element_year = 2021
@created_on_date = DateTime.current.to_s
@md5 = Digest::MD5.new

@errors = []

# padded_cms_id will always return a three digit cms identifier, e.g., CMS9v3 => CMS009v3
# Which conforms to the format used by the rest of the eCQI Resource Center
def padded_cms_id(cms_id)
  cms_id.sub(/(?<=cms)(\d{1,3})/i) { Regexp.last_match(1).rjust(3, '0') }
end

# Generate a hashed ID for an element, which should be the same as the one from the D7 DERep
def id_for(package, name)
  @md5.hexdigest("DERep-dataElement-#{package}-#{name}")
end

def execute_request(method, url, data = nil)
  puts "#{method.to_s.upcase}ing #{url}"
  begin
    res = if method == :get
            RestClient::Request.execute(method: method,
                                        url: url,
                                        user: @options['username'],
                                        password: @options['password'],
                                        verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                        headers: @base_opts)
          else
            data = JSON.generate(data) unless data.is_a? String
            RestClient::Request.execute(method: method,
                                        url: url,
                                        user: @options['username'],
                                        password: @options['password'],
                                        verify_ssl: OpenSSL::SSL::VERIFY_NONE,
                                        headers: @base_opts,
                                        payload: data)
          end
  rescue RestClient::ExceptionWithResponse => e
    @errors << { url: url, data: data, error: e }
    warn e.message
    return {}
  end
  res = JSON.parse(res)

  return res['data'] + execute_request(method, res['links']['next']['href']) if res['links']['next'] && method == :get
  res['data']
end

def hash_dataelement(term)
  { title: term.dig(:attributes, :title), version: term.dig(:attributes, :field_data_element_version), code_constraint: term.dig(:relationships, :field_code_constraint, :data), year: term.dig(:attributes, :field_year) }
end

def hash_element(term)
  { title: term.dig(:attributes, :title)&.gsub(/[^a-zA-Z0-9]/, '')&.downcase, version: term.dig(:attributes, :field_data_element_version), year: term.dig(:attributes, :field_year) }
end

# Look up a QDM DataElement by passed-in title (needed because we also hash on element version/year)
def find_qdm_element_by_title(title)
  @qdm_dataelements[
    {
      title: title.gsub(/[^a-zA-Z0-9]/, '').downcase,
      version: @options['data_element_version'],
      year: @data_element_year
    }
  ]
end

# Look up a QDM Attribute by passed in title (needed because we also hash on element version/year)
def find_qdm_attribute_by_title(title)
  @qdm_attributes[
    {
      title: title.gsub(/[^a-zA-Z0-9]/, '').downcase,
      version: @options['data_element_version'],
      year: @data_element_year
    }
  ]
end

# Look up a QDM Category by passed in title (needed because we also hash on element version/year)
def find_qdm_category_by_title(title)
  @qdm_categories[
    {
      title: @type_category_map[title].gsub(/[^a-zA-Z0-9]/, '').downcase,
      version: @options['data_element_version'],
      year: @data_element_year
    }
  ]
end

def content_or_na(content)
  if content.blank?
    '<span class="na">n/a</span>'
  else
    content.concat('<br>')
  end
end

def create_dataelement_description(clinical_focus:, data_element_scope:, inclusion_criteria:, exclusion_criteria:)
  cf = clinical_focus&.strip
  cf = content_or_na(cf)

  des = data_element_scope&.strip
  des = content_or_na(des)

  ic = inclusion_criteria&.strip
  ic = content_or_na(ic)

  ec = exclusion_criteria&.strip
  ec&.chop! if ec&.end_with? ')'
  ec = content_or_na(ec)

  %(<span class="de-label">Clinical Focus:</span> #{cf}
  <span class="de-label">Data Element Scope:</span> #{des}
  <span class="de-label">Inclusion Criteria:</span> #{ic}
  <span class="de-label">Exclusion Criteria:</span> #{ec})
end

# to_drupal_lookup_table takes an array of Drupal objects from JSON API calls, and turns them into a hash
# key of the hash = a "lookup key" for the object, usually either the name or a string of attributes put together
# value of the hash = a second hash with "type" and "id" attributes, which is the format that the JSON API uses
# for references between objects
def to_drupal_lookup_table(ary)
  ary.map do |term|
    [yield(term), { type: term['type'], id: term['id'] }]
  end.to_h
end

def to_drupal_lookup_table_with_description(ary)
  ary.map do |term|
    [yield(term), { drupal_hash: { type: term['type'], id: term['id'] }, description: term.dig('attributes', 'description', 'value'), name: term.dig('attributes', 'name') }]
  end.to_h
end

def to_drupal_lookup_table_with_revisions(ary)
  ary.map do |term|
    [yield(term), { type: term['type'], id: term['id'], meta: { target_revision_id: term['attributes']['drupal_internal__revision_id'] } }]
  end.to_h
end

# Get the taxonomy of package types from Drupal, then turn them into a hash where:
# key = the package name (e.g. "ecqm.dataelement")
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@data_element_packages = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/taxonomy_term/data_element_package")) { |term| term['attributes']['name'] }

# "stages" are the statuses of a data element (such as 'draft', 'active', and 'retired')
# key = stage name (e.g. 'active')
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@data_element_stages = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/taxonomy_term/data_element_stage")) { |term| term['attributes']['name'] }

# Code constraint types are either 'Direct Reference Code' or 'Value Set'
# key = constraint name (e.g. 'Value Set')
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@code_constraint_types = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/taxonomy_term/code_type")) { |term| term['attributes']['name'] }

# Base element types are the taxonomy terms representing QDM Data Types
# key = term name (e.g. '')
# value = a hash with a drupal hash (with type and ID), as well as a 'name' and 'description'
@base_element_types = to_drupal_lookup_table_with_description(execute_request(:get, "#{@options['base_url']}/jsonapi/taxonomy_term/qdm_datatype?filter[field_year]=#{@data_element_year}")) { |term| term['attributes']['name'].gsub('/', ' ') }

# A hash of all the code constraints that exist in Drupal
# Note: this hash gets updated as we POST new code constraints within this exporter
# key = a hash of the code constraint details (code system, oid, and display name, delimited by dashes)
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@code_constraints = to_drupal_lookup_table_with_revisions(execute_request(:get, "#{@options['base_url']}/jsonapi/paragraph/code_constraint")) { |term| "#{term['attributes']['field_code_system']}-#{term['attributes']['field_oid']}-#{term['attributes']['field_name']}-#{term['attributes']['field_url']['uri']}" }

# A hash of the qdm.dataelement data element objects, to be used as "base types"
# The filter filters by the ID of 'qdm.dataelement' in the package taxonomy
# key = a hash of the code constraint details (code system, oid, and display name, delimited by dashes)
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@qdm_dataelements = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/node/data_element2?filter[field_package.id]=#{@data_element_packages['qdm.dataelement'][:id]}")) { |term| hash_element(term.deep_symbolize_keys) }

# A hash of the qdm.category data element objects
# The filter filters by the ID of 'qdm.category' in the package taxonomy
# key = a hash of the code constraint details (code system, oid, and display name, delimited by dashes)
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@qdm_categories = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/node/data_element2?filter[field_package.id]=#{@data_element_packages['qdm.category'][:id]}")) { |term| hash_element(term.deep_symbolize_keys) }

# A hash of the ecqm.dataelement data element objects. These are the whole reason the site exists.
# The filter filters by the ID of 'ecqm.dataelement' in the package taxonomy
# NOTE: these get added to when new data elements are built in this script
# key = a hash of various elements of the ecqm data element (title, code constraint OID/codesystem, version, etc)
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@ecqm_dataelements = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/node/data_element2?filter[field_package.id]=#{@data_element_packages['ecqm.dataelement'][:id]}&filter[field_year]=#{@data_element_year}")) { |term| hash_dataelement(term.deep_symbolize_keys) }

# A hash of the electronic clinical quality emasure objects (built by Battelle, not us)
# key = the CMS ID of the measure (which is version specific, aka it's different between annual update years)
# value = a hash with "type" and "id" attributes, that can be used in building other Drupal objects
@drupal_measures = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/node/clinical_quality_measure")) { |term| term['attributes']['field_cms_id'] }

@qdm_attributes = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/node/data_element2?filter[field_package.id]=#{@data_element_packages['qdm.attribute'][:id]}")) { |term| hash_element(term.deep_symbolize_keys) }

@ecqm_unions = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/node/data_element2?filter[field_package.id]=#{@data_element_packages['ecqm.unions'][:id]}")) { |term| hash_element(term.deep_symbolize_keys) }

@views = to_drupal_lookup_table(execute_request(:get, "#{@options['base_url']}/jsonapi/view/view")) { |term| term['attributes']['drupal_internal__id'] }

modelinfo = File.open('script/noversion/model_info_file_5_4.xml') { |f| Nokogiri::XML(f) }

# Datatypes (keys are the datatype name, values are the datatype attributes)
@datatypes = {}

ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'ACE'
  inflect.acronym 'ARB'
  inflect.acronym 'VTE'
  inflect.acronym 'CD4'
  inflect.acronym 'DEXA'
  inflect.acronym 'PROMIS'
  inflect.acronym 'HOOS'
  inflect.acronym 'VR12'
  inflect.acronym 'VR'
  inflect.acronym 'MCS'
  inflect.acronym 'PCS'
  inflect.acronym 'DTaP'
  inflect.acronym 'HIV'
  inflect.acronym 'ESRD'
  inflect.acronym 'ASCVD'
  inflect.acronym 'PCI'
  inflect.acronym 'CABG'
  inflect.acronym 'II'
  inflect.acronym 'III'
  inflect.acronym 'INR'
  inflect.acronym 'MMR'
  inflect.acronym 'ED'
  inflect.acronym 'IgG'
  inflect.acronym 'HCL'
  inflect.acronym 'LVSD'
  inflect.acronym 'VFP'
  inflect.acronym 'IPC'
  inflect.acronym 'GCS'
  inflect.acronym 'ADHD'
  inflect.acronym 'VZV'
  inflect.acronym 'PAD'
  inflect.acronym 'BMI'
  inflect.acronym 'ECG'
  inflect.acronym 'FOBT'
  inflect.acronym 'IPV'
  inflect.acronym 'ICU'
  inflect.acronym 'NICU'
  inflect.acronym 'PCP'
  inflect.acronym 'SCIP'
  inflect.acronym 'SCIPVTE'
  inflect.acronym 'tPA'
  inflect.acronym 'MI'
  inflect.acronym 'LDL'
  inflect.acronym 'BP'
  inflect.acronym 'HiB'
end

# Loop through each typeInfo node (each of these is a QDM datatype)
modelinfo.xpath('//ns4:typeInfo').each do |type|
  # Grab the name of this QDM datatype
  datatype_name = type.attributes['name'].value.split('.').last

  # Grab the QDM attributes for this datatype
  attributes = []
  type.xpath('./ns4:element').each do |attribute|
    # Grab the name of this QDM datatype attribute
    attribute_name = attribute.attributes['name'].value

    # Grab the type of this QDM datatype attribute
    attribute_type = if attribute.attributes['type']
                       attribute.attributes['type'].value
                     else
                       'System.Any'
                     end

    next if attribute_name.blank? || attribute_type.blank?

    # Store name and type
    attributes << { name: attribute_name, type: attribute_type }
  end

  # Store datatype and its attributes (reject irrelevant datatypes)
  next if datatype_name.include?('Negative') || datatype_name.include?('Positive') || datatype_name.include?('QDMBaseType')

  @datatypes[datatype_name] = attributes
end

@value_set_hash = {}
completed_measures = []
@vs_measure = {}
@measure_vs = {}
def_status_att_cl = {}
@measure_unions = {}
@vs_desc = {}
@def_stat = {}

def new_or_exisiting_vs_name(vs_oid, display_name, index = 0)
  if index == 0 && @value_set_hash.value?({ :display_name => display_name })
    new_or_exisiting_vs_name(vs_oid, display_name, 1)
  elsif index > 0 && @value_set_hash.value?({ :display_name => display_name + ' ' + index.to_s })
    new_or_exisiting_vs_name(vs_oid, display_name, index + 1)
  else
    display_name = index == 0 ? display_name : display_name + ' ' + index.to_s
    @value_set_hash[vs_oid] = { display_name: display_name }
  end
end

@valuesets.each do |vs|
  next if @value_set_hash.key?(vs['oid'])
  new_or_exisiting_vs_name(vs['oid'], vs['display_name'])
end

def as_columns(key, key_size)
  split_key = key.split(':')
  if split_key.size == key_size
    return split_key
  else
    if key_size == 3
      return [split_key[0], split_key[1], split_key[2]]
    else
      return [split_key[0], split_key[1], split_key[2], split_key[3], split_key[4]]
    end
  end
end

@default_code_system_versions = {
  'AdministrativeGender' => 'HL7V3.0_2019-03',
  'CPT' => '2020',
  'CVX' => '2020-03',
  'ICD10CM' => '2020',
  'LOINC' => '2.67',
  'RXNORM' => '2020-03',
  'SNOMEDCT' => '2020-03'
}

def generate_url(concept)
  codesystem = concept.code_system_name.gsub(/[^A-Za-z0-9]/, '')
  version = concept.code_system_version ? concept.code_system_version.split(':').last : @default_code_system_versions[codesystem]
  code = concept.code
  "https://vsac.nlm.nih.gov/context/cs/codesystem/#{codesystem}/version/#{version}/code/#{code}/info"
end

# All but pre-rulemaking measures
measures.nin(category: 'Pre-rulemaking').each do |measure|
  next if completed_measures.include? measure.cms_id
  dcab = Cypress::DataCriteriaAttributeBuilder.new
  dcab.build_data_criteria_for_measure(measure)

  @measure_unions[measure.cms_id] = { unions: dcab.unions, dcab: dcab }

  completed_measures << measure.cms_id
  measure.source_data_criteria.each do |sdc|
    # Necessary because cqm-models insists the category is 'condition'
    sdc['qdmCategory'] = 'diagnosis' if sdc['qdmCategory'] == 'condition'
    sdc['qdmStatus'] = 'order' if sdc['qdmStatus'] == 'ordered'

    if sdc.dataElementAttributes && !sdc.dataElementAttributes&.empty?
      sdc.dataElementAttributes.each do |att|
        ds = sdc['qdmStatus'] ? sdc['qdmCategory'] + ':' + sdc['qdmStatus'] : sdc['qdmCategory'] + ':'
        dsa = ds + ':' + att[:attribute_name]
        if att.attribute_valueset
          dsa = dsa + ':' + att.attribute_valueset
        else
          dsa = dsa + ':'
        end
        dsac = dsa + ':' + sdc['codeListId']
        def_status_att_cl[dsac] ? def_status_att_cl[dsac] << measure.cms_id : def_status_att_cl[dsac] = [measure.cms_id]
      end
    else
      sdc['qdmStatus'] = 'sex' if sdc['qdmStatus'] == 'gender'
      ds = sdc['qdmStatus'] ? sdc['qdmCategory'] + ':' + sdc['qdmStatus'] + '::' : sdc['qdmCategory'] + ':::'
      dsc = ds + ':' + sdc['codeListId']
      def_status_att_cl[dsc] ? def_status_att_cl[dsc] << measure.cms_id : def_status_att_cl[dsc] = [measure.cms_id]
    end
  end
end
def_status_att_cl.each_key { |key| def_status_att_cl[key] = def_status_att_cl[key].uniq }
b_hash = Hash[def_status_att_cl.sort]

b_hash.each do |key, measure_ids|
  split_key = key.split(':')
  @def_stat[split_key[0]] ? @def_stat[split_key[0]] << split_key[1] : @def_stat[split_key[0]] = [split_key[1]]
  vs_oid = split_key[4]
  data_type_name = "#{split_key[0]} #{split_key[1]}".titleize.strip
  name_for_extension = split_key[1] == '' ? split_key[0] : split_key[1]
  data_type = { type_definition: split_key[0].titleize.strip,
                type_status: split_key[1].titleize.strip,
                vs_extension_name: name_for_extension.titleize.strip }
  @value_set_hash[vs_oid][:data_types] = {} unless @value_set_hash[vs_oid][:data_types]
  @value_set_hash[vs_oid][:data_types][data_type_name] = data_type unless @value_set_hash[vs_oid][:data_types][data_type_name]
  if @value_set_hash[vs_oid][:data_types][data_type_name][:measures].present?
    @value_set_hash[vs_oid][:data_types][data_type_name][:measures].concat(measure_ids).uniq!
  else
    @value_set_hash[vs_oid][:data_types][data_type_name][:measures] = measure_ids.uniq
  end
  @value_set_hash[vs_oid][:data_types][data_type_name][:measures].each do |measure_id|
    @vs_measure[vs_oid] ? @vs_measure[vs_oid] << measure_id : @vs_measure[vs_oid] = [measure_id]
    @measure_vs[measure_id] ? @measure_vs[measure_id] << vs_oid : @measure_vs[measure_id] = [vs_oid]
  end
  if split_key[2] != ''
    @value_set_hash[vs_oid][:data_types][data_type_name][:attributes] = [] unless @value_set_hash[vs_oid][:data_types][data_type_name][:attributes]
    @value_set_hash[vs_oid][:data_types][data_type_name][:attributes] << split_key[2] unless @value_set_hash[vs_oid][:data_types][data_type_name][:attributes].include?(split_key[2])
  end
  if split_key[3] != ""
    attribute_oid = split_key[3]
    @value_set_hash[attribute_oid] = {} unless @value_set_hash[attribute_oid]
    @value_set_hash[attribute_oid][:attribute_types] = [] unless @value_set_hash[attribute_oid][:attribute_types]
    attribute_name = split_key[2].titleize
    @value_set_hash[attribute_oid][:attribute_types] << attribute_name unless @value_set_hash[attribute_oid][:attribute_types].include?(attribute_name)
    measure_list = @value_set_hash[attribute_oid][:measures] ? @value_set_hash[attribute_oid][:measures] : []
    @value_set_hash[attribute_oid][:measures] = measure_list + measure_ids.uniq
    measure_ids.uniq.each do |measure_id|
      @vs_measure[attribute_oid] ? @vs_measure[attribute_oid] << measure_id : @vs_measure[attribute_oid] = [measure_id]
      @measure_vs[measure_id] ? @measure_vs[measure_id] << attribute_oid : @measure_vs[measure_id] = [attribute_oid]
    end
  end
end

csv_text = File.read('script/noversion/ep_ec_eh_unique_vs_20200507.csv')
csv = CSV.parse(csv_text, headers: true)
csv.each do |row|
  @vs_desc[row['Value Set OID']] = create_dataelement_description(
    clinical_focus: row['Purpose: Clinical Focus'],
    data_element_scope: row['Purpose: Data Element Scope'],
    inclusion_criteria: row['Purpose: Inclusion Criteria'],
    exclusion_criteria: row['Purpose: Exclusion Criteria']
  )
end

@vs_measure.each_key { |key| @vs_measure[key] =  @vs_measure[key].uniq }
@measure_vs.each_key { |key| @measure_vs[key] =  @measure_vs[key].uniq }
@def_stat.each_key { |key| @def_stat[key] = @def_stat[key].uniq }

@all_unions_with_name = {}
@all_unions_generic_name = {}

def new_or_exisiting_union(cms_id, union_name, union_values, index = 0)
  if @all_unions_with_name.key?(union_name)
    if @all_unions_with_name[union_name][:values] == union_values
      @all_unions_with_name[union_name][:cms_ids] << cms_id
    elsif @all_unions_with_name["#{union_name}#{index}"].nil?
      @all_unions_with_name["#{union_name}#{index}"] = { cms_ids: [cms_id], values: union_values }
    elsif @all_unions_with_name["#{union_name}#{index}"][:values] != union_values
      new_or_exisiting_union(cms_id, union_name, union_values, index + 1)
    end
  else
    @all_unions_with_name[union_name] = { cms_ids: [cms_id], values: union_values }
  end
end

@measure_unions.each do |cms_id, union_hash|
  union_hash[:unions].each do |union_name, union_values|
    sorted_values = @measure_unions[cms_id][:dcab].find_root_vs(union_values.sort).uniq
    @measure_unions[cms_id][:unions][union_name] = sorted_values
    new_or_exisiting_union(cms_id, union_name, sorted_values)
  end
end

@grouping_index = 1

def new_or_exising_group(union_key, union_values, cms_ids)
  if @all_unions_generic_name.key?(union_values)
    @all_unions_generic_name[union_values][:union_keys] << union_key
    @all_unions_generic_name[union_values][:cms_ids] + cms_ids
  else
    @all_unions_generic_name[union_values] = { generic_key: "Union#{@grouping_index}", union_keys: [union_key], cms_ids: cms_ids }
    @grouping_index += 1
  end
end

all_unions = @all_unions_with_name.sort_by { |key, _value| key }
all_unions.each do |key, value|
  new_or_exising_group(key, value[:values], value[:cms_ids])
end

def find_or_create_union(element)
  elem_hash = hash_element(element[:data])
  if @ecqm_unions[elem_hash]
    puts "Union \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} found"
    return @ecqm_unions[elem_hash]
  end

  puts "Union \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} not found, creating"
  res = execute_request(:post, "#{@options['base_url']}/jsonapi/node/data_element2", JSON.generate(element))
  @ecqm_unions[hash_dataelement(res.deep_symbolize_keys)] = { type: res['type'], id: res['id'] }
end

def build_union(title:, cms_ids:, union_elements:)
  element = {
    data: {
      type: 'node--data_element2',
      attributes: {
        title: title,
        field_data_element_version: @options['data_element_version'],
        field_year: @data_element_year,
        field_filename: "ecqm-union/#{title.gsub(/[^A-Za-z0-9]/, '')}.html",
        field_data_element_id: id_for('ecqm.unions', title.gsub(/[^A-Za-z0-9]/, '')),
        field_date_generated: @created_on_date
      },
      relationships: {
        field_package: { data: @data_element_packages['ecqm.unions'] },
        field_stage: { data: @data_element_stages['Active'] },
        # Note: the '*' operator in the next line is the Ruby 'splat' operator
        # Which expands an array into a list of arguments
        field_parent_measures: { data: @drupal_measures.values_at(*cms_ids).compact },
        field_union_elements: { data: union_elements }
      }
    }
  }

  element
end

def print_union
  @all_unions_generic_name.each do |union_values, hash|
    measure_ids = hash[:cms_ids].map { |id| padded_cms_id(id) }

    hash[:union_keys].each do |union_key|
      referenced_data_elements = []
      already_included = []
      union_values.each do |vs|
        next unless @value_set_hash[vs]
        @value_set_hash[vs][:data_types]&.each do |data_type, inner_hash|
          next if already_included.include? "#{@value_set_hash[vs][:display_name]}#{data_type}"
          already_included << "#{@value_set_hash[vs][:display_name]}#{data_type}"
          concept = @valuesets.where(oid: vs).first&.concepts&.first

          title = if !inner_hash[:type_status]&.empty?
            "#{inner_hash[:type_definition]}, #{inner_hash[:type_status]}: #{@value_set_hash[vs][:display_name]}"
          else
            "#{inner_hash[:type_definition]}: #{@value_set_hash[vs][:display_name]}"
          end
          included_code_constraint = if vs.include?('drc-')
            concept = @valuesets.where(oid: vs).first&.concepts&.first
            url = generate_url(concept)
            @code_constraints["#{concept.code_system_name.upcase.gsub(/[^a-zA-Z0-9]/, '')}--#{title}-#{url}"]
          else
            url = "https://vsac.nlm.nih.gov/valueset/#{vs}/expansion/eCQM%20Update%202020-05-07"
            @code_constraints["-#{vs}-#{title}-#{url}"]
          end
          included_data_element = {
            title: title,
            version: @options['data_element_version'],
            code_constraint: included_code_constraint,
            year: @data_element_year
          }
          referenced_data_elements << @ecqm_dataelements[included_data_element]
        end
      end
      union_title = union_key.sub(/(.*[a-z])([0-9]+)\z/, '\1 \2').titleize
      element = build_union(title: "#{union_title} Union",
                            cms_ids: measure_ids,
                            union_elements: referenced_data_elements.compact)

      find_or_create_union(element)
    end
  end
end

def build_referenced_view(display_id)
  merge_hash = {
    meta: {
      display_id: display_id,
      argument: nil,
      title: '0',
      data: nil
    }
  }
  @views['data_element_references'] ? merge_hash.merge(@views['data_element_references']) : merge_hash
end

def find_or_create_qdm_category(element)
  elem_hash = hash_element(element[:data])
  if @qdm_categories[elem_hash]
    puts "QDM Category \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} found"
    return @qdm_categories[elem_hash]
  end

  puts "QDM Category \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} not found, creating"
  res = execute_request(:post, "#{@options['base_url']}/jsonapi/node/data_element2", JSON.generate(element))
  @qdm_categories[hash_element(res.deep_symbolize_keys)] = { type: res['type'], id: res['id'] }
end

def build_qdm_category(title:, description:)
  element = {
    data: {
      type: 'node--data_element2',
      attributes: {
        title: title,
        body: {
          value: description,
          format: 'body_html'
        },
        field_year: @data_element_year,
        field_data_element_version: @options['data_element_version'],
        field_filename: "qdm-category/#{title.gsub(/[^A-Za-z0-9]/, '')}.html",
        field_data_element_id: id_for('qdm.category', title.gsub(/[^A-Za-z0-9]/, '')),
        field_date_generated: @created_on_date
      },
      relationships: {
        field_package: { data: @data_element_packages['qdm.category'] },
        field_stage: { data: @data_element_stages['Active'] },
        field_direct_descendants: { data: build_referenced_view('data_element_view_ref') }
      }
    }
  }

  element
end

def find_or_create_qdm_dataelement(element)
  elem_hash = hash_element(element[:data])
  if @qdm_dataelements[elem_hash]
    puts "QDM DataElement \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} found"
    return @qdm_dataelements[elem_hash]
  end

  puts "QDM DataElement \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} not found, creating"
  res = execute_request(:post, "#{@options['base_url']}/jsonapi/node/data_element2", JSON.generate(element))
  @qdm_dataelements[hash_element(res.deep_symbolize_keys)] = { type: res['type'], id: res['id'] }
end

def build_qdm_dataelement(title:, description:, qdm_datatype:, attribute_ids:, qdm_category:)
  element = {
    data: {
      type: 'node--data_element2',
      attributes: {
        title: title,
        body: {
          value: description,
          format: 'body_html'
        },
        field_year: @data_element_year,
        field_data_element_version: @options['data_element_version'],
        field_filename: "qdm-dataelement/#{title.gsub(/[^A-Za-z0-9]/, '')}.html",
        field_data_element_id: id_for('qdm.dataelement', title.gsub(/[^A-Za-z0-9]/, '')),
        field_date_generated: @created_on_date
      },
      relationships: {
        field_qdm_datatype: { data: qdm_datatype },
        field_package: { data: @data_element_packages['qdm.dataelement'] },
        field_stage: { data: @data_element_stages['Active'] },
        field_direct_descendants: { data: build_referenced_view('data_element_view_ref') },
        field_child_attributes: { data: attribute_ids },
        field_base_element: {data: qdm_category }
      }
    }
  }

  element
end

def print_qdm_category
  csv_text = File.read('script/noversion/qdm_categories.csv')
  csv = CSV.parse(csv_text, headers: true)
  csv.each do |row|
    element = build_qdm_category(title: row['title'], description: row['description'])
    find_or_create_qdm_category(element)
  end
end

@type_category_map = {
  'Adverse Event' => 'Adverse Event',
  'Allergy Intolerance' => 'Allergy Intolerance',
  'Assessment, Order' => 'Assessment',
  'Assessment, Performed' => 'Assessment',
  'Assessment, Recommended' => 'Assessment',
  'Care Goal' => 'Care Goal',
  'Communication, Performed' => 'Communication',
  'Device, Applied' => 'Device',
  'Device, Order' => 'Device',
  'Device, Recommended' => 'Device',
  'Diagnosis' => 'Condition/Diagnosis/Problem',
  'Diagnostic Study, Order' => 'Diagnostic Study',
  'Diagnostic Study, Performed' => 'Diagnostic Study',
  'Diagnostic Study, Recommended' => 'Diagnostic Study',
  'Encounter, Order' => 'Encounter',
  'Encounter, Performed' => 'Encounter',
  'Encounter, Recommended' => 'Encounter',
  'Family History' => 'Family History',
  'Immunization, Administered' => 'Immunization',
  'Immunization, Order' => 'Immunization',
  'Intervention, Order' => 'Intervention',
  'Intervention, Performed' => 'Intervention',
  'Intervention, Recommended' => 'Intervention',
  'Laboratory Test, Order' => 'Laboratory Test',
  'Laboratory Test, Performed' => 'Laboratory Test',
  'Laboratory Test, Recommended' => 'Laboratory Test',
  'Medication, Active' => 'Medication',
  'Medication, Administered' => 'Medication',
  'Medication, Discharge' => 'Medication',
  'Medication, Dispensed' => 'Medication',
  'Medication, Order' => 'Medication',
  'Participation' => 'Participation',
  'Patient Care Experience' => 'Care Experience',
  'Patient Characteristic, Birthdate' => 'Individual Characteristic',
  'Patient Characteristic, Ethnicity' => 'Individual Characteristic',
  'Patient Characteristic, Expired' => 'Individual Characteristic',
  'Patient Characteristic, Payer' => 'Individual Characteristic',
  'Patient Characteristic, Race' => 'Individual Characteristic',
  'Patient Characteristic, Sex' => 'Individual Characteristic',
  'Physical Exam, Order' => 'Physical Exam',
  'Physical Exam, Performed' => 'Physical Exam',
  'Physical Exam, Recommended' => 'Physical Exam',
  'Procedure, Order' => 'Procedure',
  'Procedure, Performed' => 'Procedure',
  'Procedure, Recommended' => 'Procedure',
  'Provider Care Experience' => 'Care Experience',
  'Substance, Administered' => 'Substance',
  'Substance, Order' => 'Substance',
  'Substance, Recommended' => 'Substance',
  'Symptom' => 'Symptom',
  'Patient Characteristic' => 'Individual Characteristic',
  'Patient Characteristic, Clinical Trial Participant' => 'Individual Characteristic',
  'Related Person' => 'Related Person'
}

def print_qdm_dataelement
  @base_element_types.each do |title, type_hash|
    attribute_names = @datatypes[title.gsub(/[^a-zA-Z0-9]/, '')]&.map { |attr| attr[:name]}
    attribute_ids = attribute_names ? attribute_names.sort.map { |attr_name| find_qdm_attribute_by_title(attr_name) }.compact : []
    qdm_category = find_qdm_category_by_title(title)

    element = build_qdm_dataelement(
      title: title,
      description: type_hash[:description],
      qdm_datatype: type_hash[:drupal_hash],
      attribute_ids: attribute_ids,
      qdm_category: qdm_category
    )

    find_or_create_qdm_dataelement(element)
  end
end

def create_code_constraint_description(type:, display_name:, code_system_name:, url:, oid:)
  case type
  when 'Value Set'
    return "<p>Constrained to codes in the #{display_name} value set <a href='#{url}' target='_blank' rel='noopener noreferrer'> <code>(#{oid})</code></a></p>"
  when 'Direct Reference Code'
    return "<p>Constrained to '#{display_name}' <a href='#{url}' target='_blank' rel='noopener noreferrer'><code>#{code_system_name} code</code></a></p>"
  end
end

def find_or_create_code_constraint(type:, display_name:, code_system_name:, url:, oid:)
  hash = "#{code_system_name}-#{oid}-#{display_name}-#{url}"
  cc = @code_constraints[hash]
  return cc if cc

  cc_obj = {
    data: {
      type: 'paragraph--code_constraint',
      attributes: {
        status: true,
        field_code_system: code_system_name,
        field_name: display_name.truncate(255),
        field_oid: oid,
        field_url: {
          uri: url,
          title: "(#{oid})"
        },
        field_description: {
          value: create_code_constraint_description(type: type, display_name: display_name, code_system_name: code_system_name, url: url, oid: oid),
          format: 'body_html'
        }
      },
      relationships: {
        field_code_type: {
          data: @code_constraint_types[type]
        }
      }
    }
  }
  ret = execute_request(:post, "#{@options['base_url']}/jsonapi/paragraph/code_constraint", cc_obj)
  if ret.present?
    @code_constraints[hash] = { type: 'paragraph--code_constraint', id: ret['id'], meta: { target_revision_id: ret['attributes']['drupal_internal__revision_id'] } }
    return @code_constraints[hash]
  end
  nil
end

def find_or_create_ecqm_dataelement(element)
  if @ecqm_dataelements[hash_dataelement(element[:data])]
    puts "Element \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} found"
    return @ecqm_dataelements[hash_dataelement(element[:data])]
  end
  puts "Element \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} not found, creating"
  res = execute_request(:post, "#{@options['base_url']}/jsonapi/node/data_element2", JSON.generate(element))
  @ecqm_dataelements[hash_dataelement(res.deep_symbolize_keys)] = { type: res['type'], id: res['id'] }
end

def build_dataelement(title:, typedef:, vs_description:, oid:, cms_ids:, attribute_ids:)
  element = {
    data: {
      type: 'node--data_element2',
      attributes: {
        title: title,
        body: {
          value: vs_description,
          format: 'body_html'
        },
        field_data_element_version: @options['data_element_version'],
        field_year: @data_element_year,
        field_filename: "ecqm-dataelement/#{title.gsub(/[^A-Za-z0-9]/, '')}.html",
        field_data_element_id: id_for('ecqm.dataelement', title.gsub(/[^A-Za-z0-9]/, '')),
        field_date_generated: @created_on_date
      },
      relationships: {
        field_package: { data: @data_element_packages['ecqm.dataelement'] },
        field_stage: { data: @data_element_stages['Active'] },
        field_base_element: { data: typedef },
        # Note: the '*' operator in the next line is the Ruby 'splat' operator
        # Which expands an array into a list of arguments
        field_parent_measures: { data: @drupal_measures.values_at(*cms_ids).compact },
        field_child_attributes: { data: attribute_ids }
      }
    }
  }

  if oid.include?('drc-')
    concept = @valuesets.where(oid: oid).first&.concepts&.first
    element[:data][:relationships][:field_code_constraint] = { data:
                                  find_or_create_code_constraint(type: "Direct Reference Code",
                                    display_name: concept.display_name,
                                    oid: nil,
                                    code_system_name: concept.code_system_name.upcase.gsub(/[^a-zA-Z0-9]/, ''),
                                    url: generate_url(concept))
                                  }
  else
    element[:data][:relationships][:field_code_constraint] = { data: 
                                  find_or_create_code_constraint(type: "Value Set",
                                    display_name: title,
                                    oid: oid,
                                    code_system_name: nil,
                                    url: "https://vsac.nlm.nih.gov/valueset/#{oid}/expansion/eCQM%20Update%202020-05-07")
                                  }
  end
  element
end

def print_ecqm_dataelement
  sorted_vs = @value_set_hash.sort_by { |_key, value| value[:display_name] || 'zzz' }
  sorted_vs.each do |oid, vs_hash|
    next unless @vs_measure[oid]
    if vs_hash[:data_types]
      vs_description = @vs_desc[oid] ? @vs_desc[oid].tr('"', "'") : ''
      vs_hash[:data_types].each do |data_type, dt_hash|
        measure_ids = dt_hash[:measures].uniq.map { |id| padded_cms_id(id) }

        attribute_ids = dt_hash[:attributes] ? dt_hash[:attributes].sort.map { |attr_name| find_qdm_attribute_by_title(attr_name) } : []

        if attribute_ids.include?(nil)
          raise NotImplementedError, "Missing attribute: #{dt_hash[:attributes].sort[attribute_ids.index(nil)]}"
        end

        element = if data_type != dt_hash[:vs_extension_name]
                    build_dataelement(title: "#{dt_hash[:type_definition]}, #{dt_hash[:type_status]}: #{vs_hash[:display_name]}".truncate(255),
                                      typedef: find_qdm_element_by_title(data_type),
                                      vs_description: vs_description,
                                      oid: oid,
                                      cms_ids: measure_ids,
                                      attribute_ids: attribute_ids)
                  else
                    build_dataelement(title: "#{dt_hash[:type_definition]}: #{vs_hash[:display_name]}".truncate(255),
                                      typedef: find_qdm_element_by_title(data_type),
                                      vs_description: vs_description,
                                      oid: oid,
                                      cms_ids: measure_ids,
                                      attribute_ids: attribute_ids)
                  end
        find_or_create_ecqm_dataelement(element)
      end
    end
    next unless vs_hash[:attribute_types]
    vs_description = @vs_desc[oid] ? @vs_desc[oid].tr('"', "'") : ''

    next if vs_hash[:display_name].nil?
    vs_hash[:attribute_types].each do |att|
      element = build_dataelement(
        title: "#{att}: #{vs_hash[:display_name].titleize}".truncate(255),
        typedef: find_qdm_attribute_by_title(att),
        vs_description: vs_description,
        oid: oid,
        cms_ids: vs_hash[:measures].uniq.map { |id| padded_cms_id(id) },
        attribute_ids: []
      )
      find_or_create_ecqm_dataelement(element)
    end
  end
end

def build_qdm_attribute(title:, description:)
  element = {
    data: {
      type: 'node--data_element2',
      attributes: {
        title: title,
        body: {
          value: description,
          format: 'body_html'
        },
        field_year: @data_element_year,
        field_data_element_version: @options['data_element_version'],
        field_filename: "qdm-attribute/#{title.gsub(/[^A-Za-z0-9]/, '')}.html",
        field_data_element_id: id_for('qdm.attribute', title.gsub(/[^A-Za-z0-9]/, '')),
        field_date_generated: @created_on_date
      },
      relationships: {
        field_package: { data: @data_element_packages['qdm.attribute'] },
        field_stage: { data: @data_element_stages['Active'] },
        field_used_by: {  data: build_referenced_view('data_element_used_by_ref') }
      }
    }
  }

  element
end

def find_or_create_qdm_attribute(element)
  elem_hash = hash_element(element[:data])
  if @qdm_attributes[elem_hash]
    puts "QDM Attribute \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} found"
    return @qdm_attributes[elem_hash]
  end

  puts "QDM Attribute \"#{element[:data][:attributes][:title]}\" version #{element[:data][:attributes][:field_data_element_version]} year #{element[:data][:attributes][:field_year]} not found, creating"
  res = execute_request(:post, "#{@options['base_url']}/jsonapi/node/data_element2", JSON.generate(element))
  @qdm_attributes[hash_element(res.deep_symbolize_keys)] = { type: res['type'], id: res['id'] }
end

def print_qdm_attributes
  csv_text = File.read('script/noversion/qdm_attributes.csv')
  csv = CSV.parse(csv_text, headers: true)
  csv.each do |row|
    element = build_qdm_attribute(title: row['title'], description: row['description'])
    find_or_create_qdm_attribute(element)
  end
end

print_qdm_category
print_qdm_attributes
print_qdm_dataelement
print_ecqm_dataelement
print_union

File.open('errors.json', 'w') { |f| f.write(JSON.pretty_generate(@errors)) } 
