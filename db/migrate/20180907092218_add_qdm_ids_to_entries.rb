class AddQdmIdsToEntries < Mongoid::Migration
  def self.up
    say_with_time 'Adding QDM Ids to Entries' do
      updated_patients_references = {}
      CQM::Patient.all.each do |patient|
        data_elements_ids_to_remove = []
        data_elements_ids_to_replace = []
        patient.dataElements.each_with_index do |de, index|
          new_id = QDM::Id.new(value: de._id.to_s)
          de.id = new_id
          if de.is_a?(QDM::CommunicationFromProviderToProvider) && de['relatedTo'] && de['relatedTo'].size > 0
            data_elements_ids_to_remove = patient.dataElements.clone
            new_comm = QDM::CommunicationFromProviderToProvider.new( dataElementCodes: de.dataElementCodes,
                                                                     authorDatetime: de.authorDatetime,
                                                                     description: de.description,
                                                                     hqmfOid: '2.16.840.1.113883.3.560.1.29' )
            de['relatedTo'].each do |related_to_id|
              new_related_to_id = QDM::Id.new(value: related_to_id.to_s)
              new_comm.relatedTo << new_related_to_id
            end
            data_elements_ids_to_replace << new_comm
            de.hqmfOid = nil
            de['relatedTo'] = nil
          end
        end
        if !data_elements_ids_to_remove.empty?
          new_patient = CQM::Patient.new( qdmVersion: patient.qdmVersion,
                                          birthDatetime: patient.birthDatetime,
                                          extendedData: patient.extendedData,
                                          familyName: patient.familyName,
                                          givenNames: patient.givenNames,
                                          bundleId: patient.bundleId)
          data_elements_ids_to_remove.delete_if { |de| de.hqmfOid == nil }
          data_elements_ids_to_remove.each do |de|
            new_patient.dataElements << de
          end
          data_elements_ids_to_replace.each do |de|
            new_patient.dataElements << de
          end
          updated_patients_references[patient.id] = new_patient.id
          irs_to_update = CQM::IndividualResult.where('patient_id' => patient.id)
          irs_to_update.each do |ir_to_update|
            ir_to_update.patient_id = new_patient.id
            ir_to_update.save!
          end
          new_patient.save
          patient.destroy
          next
        end
        patient.save!
      end
      updated_patients_references.each do |original_patient_id, updated_patient_id|
        patients_to_update = CQM::Patient.where('extendedData.original_patient' => original_patient_id)
        patients_to_update.each do |patient_to_update|
          patient_to_update.extendedData['original_patient'] = updated_patient_id
          patient_to_update.save!
        end
      end
    end
  end

  def self.down
    raise Mongoid::IrreversibleMigration
  end
end
