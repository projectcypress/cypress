namespace :qrda do
  desc "Validate that a QRDA Cat 1 document conforms to the schematron rules set up for it"
  task :validate, [:qrda_file] => :environment do |t, args|
    qrda_path = Pathname.new(args.qrda_file)
    measure_id = qrda_path.dirname.basename.to_s
    measure = Measure.where(hqmf_id: measure_id).first
    if measure.nil?
      puts "Can't find measure with a hqmf_id of #{measure_id}"
    end
    doc = File.read(args.qrda_file)
    errors = Cypress::QrdaUtility.validate_cat_1(doc, [measure])
    errors.reject! { |e| e.msg_type == :warning }

    if errors.empty?
      puts "Valid QRDA Cat 1 file: #{args.qrda_file}"
    else
      errors.each do |error|
        puts 'Message:'
        puts error.message
        puts 'Location:'
        puts error.location
        puts '--------------------------------------------------'
      end
      puts "#{errors.length} errors found for mesure #{measure.nqf_id} in #{args.qrda_file}"
    end
  end




  desc 'Generate measure rationale'
  task :generate_smoking_gun => :environment do |t, args|
    
    # def loop_data_criteria(measure, data_criteria, rationale, result)
    #   if (rationale[data_criteria.id])

    #     if data_criteria.type != :derived
    #       template = HQMF::DataCriteria.template_id_for_definition(data_criteria.definition, data_criteria.status, data_criteria.negation)
    #       value_set_oid = data_criteria.code_list_id
    #       begin
    #         qrda_template = HealthDataStandards::Export::QRDA::EntryTemplateResolver.qrda_oid_for_hqmf_oid(template,value_set_oid)
    #       rescue
    #         value_set_oid = 'In QRDA Header (Non Null Value)'
    #         qrda_template = 'N/A'
    #       end
    #       description = "#{HQMF::DataCriteria.title_for_template_id(template).titleize}: #{data_criteria.title}"
    #       result << {description: description, oid: value_set_oid, template: qrda_template}

    #       if data_criteria.temporal_references
    #         data_criteria.temporal_references.each do |temporal_reference|
    #           if temporal_reference.reference.id != 'MeasurePeriod'
    #             loop_data_criteria(measure, measure.data_criteria(temporal_reference.reference.id), rationale, result)
    #           end
    #         end
    #       end
    #     else
    #       if data_criteria.children_criteria
    #         data_criteria.children_criteria.each do |child_id|
    #           loop_data_criteria(measure, measure.data_criteria(child_id), rationale, result)
    #         end
    #       end
    #     end
    #   end
    # end

    # def loop_preconditions(measure, parent, rationale, result)
    #   parent.preconditions.each do |precondition|
    #     parent_key = "precondition_#{parent.id}"
    #     key = "precondition_#{precondition.id}"
    #     if precondition.preconditions.empty?
    #       data_criteria = measure.data_criteria(precondition.reference.id)
    #       loop_data_criteria(measure, data_criteria, rationale, result)
    #     else
    #       if (rationale[parent_key] && rationale[key]) 
    #         loop_preconditions(measure, precondition, rationale, result)
    #       end
    #     end
    #   end
    # end

    # measures = Measure.all
    # patient_map = Record.all.reduce({}) {|patient_map, patient| patient_map[patient.medical_record_number] = patient; patient_map}
    
    basedir = File.join('.', 'tmp','measures','smoking_gun')
    FileUtils.rm_r basedir if File.exists?(basedir)
    FileUtils.mkdir_p basedir
    
    # population_keys = ('a'..'zz').to_a
    # result = {}
    outfile = File.join(basedir, "smoking_gun.json")
     xlsfile_by_measure = File.join(basedir, "smoking_gun_by_measure.xlsx")
     xlsfile_by_patient = File.join(basedir, "smoking_gun_by_patient.xlsx")
    # measures.sort {|l,r| l.measure_id <=> r.measure_id }.each do |measure|
    #   measure.populations.each_with_index do |population,index|

    #     sub_id = nil
    #     sub_id = population_keys[index] if measure.populations.length > 1

    #     result["#{measure.measure_id}#{sub_id}"] ||= {}

    #     hqmf_measure = measure.as_hqmf_model

    #     patient_caches = MONGO_DB['patient_cache'].where({'value.nqf_id'=>measure.measure_id, 'value.sub_id'=>sub_id})
    #     count = 0
    #     patient_caches.each do |cache|
    #       if cache['value']['IPP'] > 0

    #         rationale = cache['value']['rationale']

    #         result["#{measure.measure_id}#{sub_id}"]["#{cache['value']['first']}_#{cache['value']['last']}"] ||= {}
        
    #         HQMF::PopulationCriteria::ALL_POPULATION_CODES.each do |pop_code|
    #           if (population[pop_code])
    #             population_criteria = hqmf_measure.population_criteria(population[pop_code])
    #             if population_criteria.preconditions
    #               array = []
    #               result["#{measure.measure_id}#{sub_id}"]["#{cache['value']['first']}_#{cache['value']['last']}"]["#{pop_code}"] = array
    #               parent = population_criteria.preconditions[0]
    #               loop_preconditions(hqmf_measure, parent, rationale, array)
    #             end
    #           end
    #         end
        
    #       end
    #     end

    #     puts "wrote #{count} measure #{measure.measure_id}#{sub_id} patients to: #{outfile}"
    #   end
    # end
    result  = {}
    HealthDataStandards::CQM::Measure.each {|m| result[m.nqf_id] = m.smoking_gun_data( {})}
    File.open(outfile, 'w') {|f| f.write(JSON.pretty_generate(result)) }
    puts outfile
    mrn_map = {}
    Record.where({}).each {|rec| mrn_map[rec.medical_record_number] = "#{rec.first}_#{rec.last}"}
 
    require 'rubyXL'
    
    workbook = RubyXL::Workbook.new
    workbook.worksheets = []

    result.keys.sort.each_with_index do |measure_id, index|
      worksheet = RubyXL::Worksheet.new(workbook)
      workbook.worksheets << worksheet
      worksheet.sheet_name = measure_id

      worksheet.add_cell(0,0,'Patient')
      worksheet.add_cell(0,1,'Attribute')
      worksheet.add_cell(0,2,'Value Set OID')
      worksheet.add_cell(0,3,'Template ID')

      row_index = 1;
      result[measure_id].keys.sort{|a,b| mrn_map[a] <=> mrn_map[b]}.each_with_index do |mrn, patient_row|
        worksheet.add_cell(row_index, 0,mrn_map[mrn])
        row_index+=1
        result[measure_id][mrn].flatten.uniq.sort{|l,r| l[:description] <=> r[:description]}.each do |criteria|
          worksheet.add_cell(row_index, 1, criteria[:description])
          worksheet.add_cell(row_index, 2, criteria[:oid])
          worksheet.add_cell(row_index, 3, criteria[:template])
          row_index+=1
        end
      end

    end


    by_patient = {}
    result.keys.each_with_index do |measure_id, index|
      result[measure_id].keys.sort.each_with_index do |mrn, patient_row|
        by_patient[mrn] ||= {}
        by_patient[mrn][measure_id] ||= result[measure_id][mrn].flatten.uniq.sort{|l,r| l[:description] <=> r[:description]}
      end
    end

    workbook.write(xlsfile_by_measure)

    workbook = RubyXL::Workbook.new
    workbook.worksheets = []

    by_patient.keys.sort{|a,b|  mrn_map[a] <=> mrn_map[b]}.each do |mrn|
      worksheet = RubyXL::Worksheet.new(workbook)
      workbook.worksheets << worksheet
      worksheet.sheet_name = mrn_map[mrn]

      worksheet.add_cell(0,0,'Measure')
      worksheet.add_cell(0,1,'Attribute')
      worksheet.add_cell(0,2,'Value Set OID')
      worksheet.add_cell(0,3,'Template ID')

      row_index = 1;
      by_patient[mrn].keys.sort.each do |measure_id|
        worksheet.add_cell(row_index, 0,measure_id)
        row_index+=1
        by_patient[mrn][measure_id].each do |criteria|
          worksheet.add_cell(row_index, 1, criteria[:description])
          worksheet.add_cell(row_index, 2, criteria[:oid])
          worksheet.add_cell(row_index, 3, criteria[:template])
          row_index+=1
        end
      end
    end

    workbook.write(xlsfile_by_patient)

    puts "wrote #{xlsfile_by_measure}"
    puts "wrote #{xlsfile_by_patient}"


  end

end