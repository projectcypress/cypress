require 'mongoid'
require 'csv'
require 'byebug'
require 'health-data-standards'
require 'bonnie_bundler'

Mongoid.load!('config/mongoid.yml', :development)
@valuesets = HealthDataStandards::SVS::ValueSet.all
measures = HealthDataStandards::CQM::Measure.all

modelinfo = File.open('script/noversion/model_info_file_5_3.xml') { |f| Nokogiri::XML(f) }

TYPE_LOOKUP_RB = {
  'System.DateTime': 'dateTime',
  'System.Quantity': 'Quantity',
  'System.Code': 'Coding',
  # 'System.Any': 'Any',
  'System.Integer': 'integer',
  'interval<System.DateTime>': 'TimePeriod',
  'interval<System.Quantity>': 'Range',
  # 'list<QDM.Component>': 'Array',
  'System.String': 'string',
  # 'list<QDM.Id>': 'Array',
  # 'list<QDM.ResultComponent>': 'Array',
  # 'list<QDM.FacilityLocation>': 'Array',
  'list<System.Code>': 'CodeableConcept',
  'QDM.Id': 'string',
  'System.Decimal': 'decimal',
  'System.Time': 'time',
  # 'System.Concept': 'Any'
}.stringify_keys!

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
  elsif index > 0 && @value_set_hash.value?({ :display_name => display_name + index.to_s })
    new_or_exisiting_vs_name(vs_oid, display_name, index + 1)
  else
    display_name = index == 0 ? display_name : display_name + index.to_s
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

def generate_url(concept)
  version = concept.code_system_version.split(':').last
  codesystem = concept.code_system_name.upcase.gsub(/[^A-Za-z]/, '')
  code = concept.code
  "https://vsac.nlm.nih.gov/context/cs/codesystem/#{codesystem}/version/#{version}/code/#{code}/info"
end

# Filtered measures updated by Measure Developers
# measures.in(cms_id: %w[CMS50v7 CMS149v7 CMS142v7 CMS143v7 CMS161v7 CMS129v8 CMS177v7 CMS157v7]).each do |measure|
# All but measures that were removed from the 2019 PY
measures.nin(cms_id: %w[CMS167v7 CMS123v7 CMS164v7 CMS169v7 CMS158v7 CMS65v8]).each do |measure|
  next if completed_measures.include? measure.cms_id

  dcab = Cypress::DataCriteriaAttributeBuilder.new
  dcab.build_data_criteria_for_measure(measure)

  @measure_unions[measure.cms_id] = { unions: dcab.unions, dcab: dcab }

  completed_measures << measure.cms_id
  measure['source_data_criteria'].each do |_key, sdc|
    sdc['status'] = 'order' if sdc['status'] == 'ordered'
    if sdc['attributes']
      sdc['attributes'].each do |att|
        ds = sdc['status'] ? sdc['definition'] + ':' + sdc['status'] : sdc['definition'] + ':'
        dsa = ds + ':' + att[:attribute_name]
        if att[:attribute_valueset]
          dsa = dsa + ':' + att[:attribute_valueset]
        else
          dsa + ':'
              end
        dsac = dsa + ':' + sdc['code_list_id']
        def_status_att_cl[dsac] ? def_status_att_cl[dsac] << measure.cms_id : def_status_att_cl[dsac] = [measure.cms_id]
      end
    else
      ds = sdc['status'] ? sdc['definition'] + ':' + sdc['status'] + '::' : sdc['definition'] + ':::'
      dsc = ds + ':' + sdc['code_list_id']
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
  data_type_name = "#{split_key[0]} #{split_key[1]}".titleize.gsub(/[^A-Za-z]/, '')
  name_for_extension = split_key[1] == '' ? split_key[0] : split_key[1]
  data_type = { type_definition: split_key[0].titleize.gsub(/[^A-Za-z]/, ''),
                type_status: split_key[1].titleize.gsub(/[^A-Za-z]/, ''),
                vs_extension_name: name_for_extension.titleize.gsub(/[^A-Za-z]/, '') }
  @value_set_hash[vs_oid][:data_types] = {} unless @value_set_hash[vs_oid][:data_types]
  @value_set_hash[vs_oid][:data_types][data_type_name] = data_type unless @value_set_hash[vs_oid][:data_types][data_type_name]
  @value_set_hash[vs_oid][:data_types][data_type_name][:measures] = measure_ids.uniq
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
    attribute_name = split_key[2].titleize.gsub(/[^A-Za-z]/, '')
    @value_set_hash[attribute_oid][:attribute_types] << attribute_name unless @value_set_hash[attribute_oid][:attribute_types].include?(attribute_name)
    measure_list = @value_set_hash[attribute_oid][:measures] ? @value_set_hash[attribute_oid][:measures] : []
    @value_set_hash[attribute_oid][:measures] = measure_list + measure_ids.uniq
    measure_ids.uniq.each do |measure_id|
      @vs_measure[attribute_oid] ? @vs_measure[attribute_oid] << measure_id : @vs_measure[attribute_oid] = [measure_id]
      @measure_vs[measure_id] ? @measure_vs[measure_id] << attribute_oid : @measure_vs[measure_id] = [attribute_oid]
    end
  end
end

csv_text = File.read('script/noversion/value-set-codes.csv')
csv = CSV.parse(csv_text, headers: true)
csv.each do |row|
  @vs_desc[row[0]] = row['Purpose']
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
    new_or_exisiting_union(cms_id, union_name.gsub(/[^A-Za-z0-9]/, ''), sorted_values)
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

def print_union
  File.open('./script/ecqm_unions.txt', 'w') do |f|
    f.puts 'Grammar: DataElement 5.0'
    f.puts 'Namespace: ecqm.unions'
    f.puts 'Description: "Insert Text Here"'
    f.puts 'Uses: shr.core, shr.base, shr.entity, ecqm.dataelement, ecqm.measure'
    f.puts ''
    @all_unions_generic_name.each do |union_values, hash|
      f.puts "EntryElement: #{hash[:generic_key]}"
      hash[:cms_ids].each do |cms_id|
        f.puts "    0..* #{cms_id}"
      end
      f.puts ''
      hash[:union_keys].each do |union_key|
        already_included = []
        # byebug
        f.puts "EntryElement: #{union_key.titleize.gsub(/[^A-Za-z0-9]/, '')}Union"
        f.puts "Based on: #{hash[:generic_key]}"
        hash[:cms_ids].each do |_cms_id|
          union_values.each do |vs|
            next unless @value_set_hash[vs]
            @value_set_hash[vs][:data_types]&.each do |data_type, inner_hash|
              next if already_included.include? "#{@value_set_hash[vs][:display_name]}#{data_type}"
              already_included << "#{@value_set_hash[vs][:display_name]}#{data_type}"
              f.puts "    0..* #{@value_set_hash[vs][:display_name].titleize.gsub(/[^A-Za-z0-9]/, '')}#{inner_hash[:vs_extension_name]}"
            end
          end
        end
        f.puts ''
      end
    end
  end
end

CODE_HASH = { 'AdverseEvent' => 'ResultValue',
              'AllergyIntolerance' => 'ResultValue',
              'Assessment' => 'ObservableCode',
              'CommunicationFromPatientToProvider' => 'ObservableCode',
              'CommunicationFromProviderToPatient' => 'ObservableCode',
              'CommunicationFromProviderToProvider' => 'ObservableCode',
              'Device' => 'ObjectTypeCode',
              'Diagnosis' => 'ResultValue',
              'DiagnosticStudy' => 'ObservableCode',
              'Encounter' => 'ActivityCode',
              'Immunization' => 'ObjectTypeCode',
              'Intervention' => 'ActivityCode',
              'LaboratoryTest' => 'ObservableCode',
              'Medication' => 'ObjectTypeCode',
              'PhysicalExam' => 'ObservableCode',
              'Procedure' => 'ObservableCode',
              'Substance' => 'ObjectTypeCode'}.freeze

BASED_ON_HASH = { 'AdverseEvent' => 'Observation',
                  'AllergyIntolerance' => 'Observation',
                  'Assessment' => 'Observation',
                  'AssessmentPerformed' => 'Activity',
                  'CommunicationFromPatientToProvider' => 'Observation',
                  'CommunicationFromProviderToPatient' => 'Observation',
                  'CommunicationFromProviderToProvider' => 'Observation',
                  'Device' => 'ObjectPresentOrAbsent',
                  'DeviceApplied' => 'Activity',
                  'DeviceOrder' => 'Activity',
                  'Diagnosis' => 'Observation',
                  'DiagnosticStudy' => 'Observation',
                  'DiagnosticStudyOrder' => 'Activity',
                  'DiagnosticStudyPerformed' => 'Activity',
                  'Encounter' => 'Activity',
                  'EncounterOrder' => 'Activity',
                  'EncounterPerformed' => 'Activity',
                  'Immunization' => 'ObjectPresentOrAbsent',
                  'ImmunizationAdministered' => 'Activity',
                  'Intervention' => 'Activity',
                  'InterventionOrder' => 'Activity',
                  'InterventionPerformed' => 'Activity',
                  'LaboratoryTest' => 'Observation',
                  'LaboratoryTestOrder' => 'Activity',
                  'LaboratoryTestPerformed' => 'Activity',
                  'Medication' => 'ObjectPresentOrAbsent',
                  'MedicationActive' => 'Activity',
                  'MedicationAdministered' => 'Activity',
                  'MedicationDischarge' => 'Activity',
                  'MedicationOrder' => 'Activity',
                  'PhysicalExam' => 'Observation',
                  'PhysicalExamPerformed' => 'Activity',
                  'Procedure' => 'Observation',
                  'ProcedureOrder' => 'Activity',
                  'ProcedurePerformed' => 'Activity',
                  'Substance' => 'ObjectPresentOrAbsent',
                  'SubstanceAdministered' => 'Activity'}.freeze

SUBJECT_HASH = { 'AssessmentPerformed' => 'Assessment',
                'DeviceApplied' => 'Device',
                'DeviceOrder' => 'Device',
                'DiagnosticStudyOrder' => 'DiagnosticStudy',
                'DiagnosticStudyPerformed' => 'DiagnosticStudy',
                'EncounterOrder' => 'Encounter',
                'EncounterPerformed' => 'Encounter',
                'ImmunizationAdministered' => 'Immunization',
                'InterventionOrder' => 'Intervention',
                'InterventionPerformed' => 'Intervention',
                'LaboratoryTestOrder' => 'LaboratoryTest',
                'LaboratoryTestPerformed' => 'LaboratoryTest',
                'MedicationActive' => 'Medication',
                'MedicationAdministered' => 'Medication',
                'MedicationDischarge' => 'Medication',
                'MedicationOrder' => 'Medication',
                'PhysicalExamPerformed' => 'PhysicalExam',
                'ProcedureOrder' => 'Procedure',
                'ProcedurePerformed' => 'Procedure',
                'SubstanceAdministered' => 'Substance'}.freeze

def based_on(data_type)
  BASED_ON_HASH[data_type] ? BASED_ON_HASH[data_type] : 'Observation'
end

def subject(data_type)
  SUBJECT_HASH[data_type] ? SUBJECT_HASH[data_type] : 'Patient'
end

def vs_type(data_type)
  CODE_HASH[data_type] || 'ResultValue'
end

def print_qdm_category
  File.open('./script/qdm_dataelement.txt', 'w') do |f|
    f.puts 'Grammar: DataElement 5.0'
    f.puts 'Namespace: qdm.dataelement'
    f.puts 'Description: "Insert Text Here"'
    f.puts 'Uses: shr.core, shr.base, shr.entity, qdm.attribute'

    @def_stat.each do |definition, status|
      definition_title = definition.titleize.gsub(/[^a-zA-Z]/, '')
      f.puts ''
      f.puts "EntryElement: #{definition_title}"
      f.puts "Based on: #{based_on(definition_title)}"
      f.puts "Description: \"#{definition_title}\""
      # f.puts "    ObservableCode is #TODO"
      f.puts '    Subject value is type Patient'

      status.each do |stat|
        definition_status_title = definition_title
        if stat != ''
          definition_status_title = (definition + ' ' + stat).titleize.gsub(/[^a-zA-Z]/, '')
          f.puts ''
          f.puts "EntryElement: #{definition_status_title}"
          f.puts "Based on: #{based_on(definition_status_title)}"
          f.puts "Description: \"#{definition_status_title}\""
          # f.puts "    ObservableCode is #TODO"
          f.puts "    Subject value is type #{subject(definition_status_title)}"
        end

        next unless @datatypes[definition_status_title]
        @datatypes[definition_status_title]&.each do |attribute|
          f.puts "    0..1   #{attribute[:name].titleize.gsub(/\s+/, '')}"
        end
      end
    end
  end
end

def print_ecqm_dataelement
  File.open('./script/ecqm_dataelement.txt', 'w') do |f|
    f.puts 'Grammar: DataElement 5.0'
    f.puts 'Namespace: ecqm.dataelement'
    f.puts 'Description: "Insert Text Here"'
    f.puts 'Uses: shr.core, shr.base, shr.entity, qdm.attribute, qdm.dataelement'

    # sorted_vs = @valueset_map.sort_by { |key, value| value }
    # byebug
    sorted_vs = @value_set_hash.sort_by { |_key, value| value[:display_name] || 'zzz' }
    sorted_vs.each do |oid, vs_hash|
      next unless @vs_measure[oid]
      # byebug if oid.include?('drc-')
      # if @vs_defstat[oid]
      if vs_hash[:data_types]
        vs_description = @vs_desc[oid] ? @vs_desc[oid].tr('"', "'") : ''
        exported_base_types = []
        vs_hash[:data_types].each do |data_type, dt_hash|
          if (data_type != dt_hash[:vs_extension_name]) && !exported_base_types.include?(dt_hash[:type_definition])
            f.puts ''
            f.puts "EntryElement: #{vs_hash[:display_name].titleize.gsub(/[^a-zA-Z0-9]/, '')}"
            f.puts "Based on: #{dt_hash[:type_definition]}"
            if oid.include?('drc-')
              concept = @valuesets.where(oid: oid).first&.concepts&.first
              f.puts "Description: \"#{vs_description} -- #{vs_type(dt_hash[:type_definition])} constrained to '#{concept.display_name}' #{concept.code_system_name.upcase.gsub(/[^a-zA-Z0-9]/, '')} code\""
              f.puts "#{vs_type(dt_hash[:type_definition])} from #{generate_url(concept)}"
            else
              f.puts "Description: \"#{vs_description} -- #{vs_type(dt_hash[:type_definition])} constrained to codes in the #{vs_hash[:display_name]} valueset `(#{oid})`. \""
              f.puts "#{vs_type(dt_hash[:type_definition])} from https://vsac.nlm.nih.gov/valueset/#{oid}/expansion"
            end
            exported_base_types << dt_hash[:type_definition]
          end
          if data_type != dt_hash[:vs_extension_name]
            f.puts ''
            f.puts "EntryElement: #{vs_hash[:display_name].titleize.gsub(/[^a-zA-Z0-9]/, '')}#{dt_hash[:type_status]}"
            f.puts "Based on: #{data_type}"
            f.puts "Description: \"#{vs_description} -- Subject constrained to the #{vs_hash[:display_name]}\""
            f.puts "Subject value is type #{vs_hash[:display_name].titleize.gsub(/[^a-zA-Z0-9]/, '')}"
            @datatypes[data_type].each do |attribute|
              f.puts "    0..0   #{attribute[:name].titleize.gsub(/\s+/, '')}" unless dt_hash[:attributes].nil? || dt_hash[:attributes].include?(attribute[:name])
            end
          else
            f.puts ''
            f.puts "EntryElement: #{vs_hash[:display_name].titleize.gsub(/[^a-zA-Z0-9]/, '')}#{data_type}"
            f.puts "Based on: #{data_type}"
            # Handle direct reference codess
            if oid.include?('drc-')
              concept = @valuesets.where(oid: oid).first&.concepts&.first
              f.puts "Description: \"#{vs_description} -- #{vs_type(data_type)} constrained to '#{concept.display_name}' #{concept.code_system_name.upcase.gsub(/[^a-zA-Z0-9]/, '')} code\""
              f.puts "#{vs_type(data_type)} from #{generate_url(concept)}"
            else
              f.puts "Description: \"#{vs_description} -- #{vs_type(data_type)} constrained to codes in the #{vs_hash[:display_name]} valueset `(#{oid})`\""
              f.puts "#{vs_type(data_type)} from https://vsac.nlm.nih.gov/valueset/#{oid}/expansion"
            end
            next if @datatypes[data_type].nil?
            @datatypes[data_type].each do |attribute|
              f.puts "    0..0   #{attribute[:name].titleize.gsub(/\s+/, '')}" unless dt_hash[:attributes].nil? || dt_hash[:attributes].include?(attribute[:name])
            end
          end
        end
      end
      next unless vs_hash[:attribute_types]
      vs_description = @vs_desc[oid] ? @vs_desc[oid].tr('"', "'") : ''
      next if vs_hash[:display_name].nil?
      vs_hash[:attribute_types].each do |att|
        f.puts ''
        f.puts "EntryElement: #{vs_hash[:display_name].titleize.gsub(/[^a-zA-Z0-9]/, '')}#{att}"
        f.puts "Based on: #{att}"
        f.puts "Description: \"#{vs_description}\""
        if oid.include?('drc-')
          concept = @valuesets.where(oid: oid).first&.concepts&.first
          f.puts "ResultValue from #{generate_url(concept)}"
        else
          f.puts "ResultValue from https://vsac.nlm.nih.gov/valueset/#{oid}/expansion"
        end
      end
    end
  end
end

def print_cms_ecqm
  File.open('./script/ecqm_measure.txt', 'w') do |f|
    f.puts 'Grammar: DataElement 5.0'
    f.puts 'Namespace: ecqm.measure'
    f.puts 'Description: "Insert Text Here"'
    f.puts 'Uses: shr.core, shr.base, shr.entity, ecqm.dataelement, ecqm.unions'
    f.puts 'Abstract Element: CmsEcqmComposition'
    f.puts 'Based on: Composition'
    f.puts 'Description: "Abstract eCQM Definition."'
    f.puts '    Subject value is type Patient'

    sorted_measures = @measure_vs.sort_by { |measure_id, _vs| measure_id }
    sorted_measures.each do |measure_id, vs|
      f.puts ''
      f.puts "EntryElement: #{measure_id}"
      f.puts 'Based on: CmsEcqmComposition'
      f.puts "Description: \"#{measure_id}\""
      vs -= ['']
      # byebug

      vs.each do |oid|
        next unless @value_set_hash[oid][:display_name]
        vs_name = @value_set_hash[oid][:display_name]
        @value_set_hash[oid][:data_types]&.each do |_data_type, dt_hash|
          f.puts "    0..* #{vs_name.titleize.gsub(/[^a-zA-Z0-9]/, '')}#{dt_hash[:vs_extension_name]}" if dt_hash[:measures].include?(measure_id)
        end
        next unless @value_set_hash[oid][:attribute_types]
        @value_set_hash[oid][:attribute_types]&.each do |att|
          f.puts "    0..* #{vs_name.titleize.gsub(/[^a-zA-Z0-9]/, '')}#{att}" if @value_set_hash[oid][:measures].include?(measure_id)
        end
      end
      @all_unions_with_name.each do |union_name, hash|
        hash[:cms_ids].each do |cms_id|
          next unless cms_id == measure_id
          f.puts "    0..* #{union_name.titleize.gsub(/[^a-zA-Z0-9]/, '')}Union"
        end
      end
    end
  end
end

print_union
print_cms_ecqm
print_ecqm_dataelement
# print_qdm_category  # This has human generated content
