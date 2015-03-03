# yes this is a bit ugly as it is aliasing The measure class but it
# works for now until we can truley unify these items accross applications

Measure = HealthDataStandards::CQM::Measure

class Measure
  field :bundle_id, type: BSON::ObjectId

   index :bundle_id => 1
   index :sub_id => 1
   index :_id => 1
   index id: 1, sub_id: 1

  def data_criteria
    self['hqmf_document']['data_criteria'].map {|key, val| {key => val}}
  end

  def key
    "#{self['id']}#{sub_id}"
  end

  def is_cv?
    ! population_ids[QME::QualityReport::MSRPOPL].nil?
  end

  def self.installed
    Measure.order_by([["id", :asc],["sub_id", :asc]]).to_a
  end


  # Finds all measures and groups the sub measures
  # @return Array - This returns an Array of Hashes. Each Hash will represent a top level measure with an ID, name, and category.
  #                 It will also have an array called subs containing hashes with an ID and name for each sub-measure.
  def self.all_by_measure
    reduce = 'function(obj,prev) {
                if (obj.sub_id != null)
                  prev.subs.push({id : obj.id + obj.sub_id, name : obj.subtitle});
              }'

    MONGO_DB.command( :group=> {:ns=>"measures", :key => {:id=>1, :name=>1, :category=>1}, :initial => {:subs => []}, "$reduce" => reduce})["retval"]
  end

  def display_name
    "#{self['cms_id']}/#{self['nqf_id']} - #{name}"
  end


  def set_id
    self.hqmf_set_id
  end

  def measure_id
    self['id']
  end

  def continuous?
    population_ids[QME::QualityReport::MSRPOPL]
  end

  def title
    self.name
  end

  def all_data_criteria
    return @crit if @crit
    @crit = []
    self.data_criteria.each do |dc|
      dc.each_pair do |k,v|
        @crit <<HQMF::DataCriteria.from_json(k,v)
      end
    end
    @crit
  end

  def smoking_gun_data(patient_cache_filter={})
    ::Measure.calculate_smoking_gun_data(self["bundle_id"], self.hqmf_id, patient_cache_filter)
  end
  # Calculate the smoking gun data for the given hqmf_id with the given patient_cache_filter
  # The  filter will allow us to segment the cache by things like test_id required for Cypress.

  def self.calculate_smoking_gun_data(bundle_id, hqmf_id, patient_cache_filter={})
    values = {}
    measure = Measure.top_level.where({hqmf_id: hqmf_id, bundle_id: bundle_id}).first
    hqmf_measure = measure.as_hqmf_model

    population_codes, sub_ids = self.return_population_codes(hqmf_measure)

    rationals = HealthDataStandards::CQM::PatientCache.smoking_gun_rational(measure.hqmf_id,sub_ids,patient_cache_filter)
    rationals.each_pair do |mrn,rash|
      values[mrn] = []
      population_codes.each do |pop_code|
        population_criteria = hqmf_measure.population_criteria(pop_code)
        if population_criteria.preconditions
          array = []

          parent = population_criteria.preconditions[0]
          values[mrn].concat self.loop_preconditions(hqmf_measure, parent, rash)
        end # end  population_criteria.preconditions
      end # population_codes
      values[mrn].uniq!
    end
    values
  end

  def <=> (other)
    "#{self.nqf_id}-#{self.sub_id}" <=> "#{other.nqf_id}-#{other.sub_id}"
  end

  private

  def self.return_population_codes(mes)
    population_codes = []
    sub_ids = []
    population_keys = ('a'..'zz').to_a
    if  mes.populations.length == 1
      sub_ids = nil
      population = mes.populations[0]
      HQMF::PopulationCriteria::ALL_POPULATION_CODES.each do |code|
            population_codes <<  population[code] if population[code]
      end
    else
      #Do not bother with populaions that contain stratifications
      mes.populations.each_with_index do |population,index|
        if population["stratification"].nil?
          sub_ids << population_keys[index]
          HQMF::PopulationCriteria::ALL_POPULATION_CODES.each do |code|
            population_codes <<  population[code] if population[code]
          end
        end
      end
    end

    return population_codes.uniq, sub_ids
  end

  def self.loop_data_criteria(hqmf, data_criteria, rationale)
    result = []
    if (rationale[data_criteria.id])

      if data_criteria.type != :derived
        template = HQMF::DataCriteria.template_id_for_definition(data_criteria.definition, data_criteria.status, data_criteria.negation)
        value_set_oid = data_criteria.code_list_id
        begin
          qrda_template = HealthDataStandards::Export::QRDA::EntryTemplateResolver.qrda_oid_for_hqmf_oid(template,value_set_oid)
        rescue
          value_set_oid = 'In QRDA Header (Non Null Value)'
          qrda_template = 'N/A'
        end # end begin recue
         description = "#{HQMF::DataCriteria.title_for_template_id(template).titleize}: #{data_criteria.title}"
         result << {description: description, oid: value_set_oid, template: qrda_template, rationale: rationale[data_criteria.id]}
        if data_criteria.temporal_references
          data_criteria.temporal_references.each do |temporal_reference|
            if temporal_reference.reference.id != 'MeasurePeriod'
              result.concat loop_data_criteria(hqmf, hqmf.data_criteria(temporal_reference.reference.id), rationale)
            end  #if temporal_reference.reference.id
          end # end  data_criteria.temporal_references.each do |temporal_reference|
        end# end if data_criteria.temporal_references
      else #data_criteria.type != :derived
        (data_criteria.children_criteria || []).each do |child_id|
          result.concat loop_data_criteria(hqmf, hqmf.data_criteria(child_id), rationale)
        end
      end
    end
    result
  end

  def self.loop_preconditions(hqmf, parent, rationale)
    result = []
    parent.preconditions.each do |precondition|
      parent_key = "precondition_#{parent.id}"
      key = "precondition_#{precondition.id}"
      if precondition.preconditions.empty?
        data_criteria = hqmf.data_criteria(precondition.reference.id)
        result.concat loop_data_criteria(hqmf, data_criteria, rationale)
      else
        if (rationale[parent_key] && rationale[key])
          result.concat  loop_preconditions(hqmf, precondition, rationale)
        end
      end
    end
    result
  end

end
