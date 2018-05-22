FactoryGirl.define do
  factory :measure, class: Measure do
    sequence(:name) { |i| "Measure Name #{i}" }
    sequence(:hqmf_id) { |i| "53e3f13d-e5cf-445f-8dda-3720aff8401#{i}" }
    sequence(:hqmf_set_id) { |i| "7c00e09b-02dc-458b-8587-7f0347a443f#{i}" }
    continuous_variable false
    category 'none'
    type 'ep'
    episode_of_care true
    trait :diagnosis do
      hqmf_doc = { 'source_data_criteria' => { 'DiagnosisActivePregnancy' =>
                                               { 'title' => 'Pregnancy',
                                                 'description' => 'Diagnosis, Active=> Pregnancy',
                                                 'standard_category' => 'diagnosis_condition_problem',
                                                 'qds_data_type' => 'diagnosis_active',
                                                 'code_list_id' => '1.5.6.7',
                                                 'type' => 'conditions',
                                                 'definition' => 'diagnosis',
                                                 'hard_status' => false,
                                                 'negation' => false,
                                                 'source_data_criteria' => 'DiagnosisActivePregnancy' } },
                   'data_criteria' => { 'DiagnosisActivePregnancy' =>
                                        { 'title' => 'Pregnancy',
                                          'description' => 'Diagnosis, Active=> Pregnancy',
                                          'standard_category' => 'diagnosis_condition_problem',
                                          'qds_data_type' => 'diagnosis_active',
                                          'code_list_id' => '1.5.6.7',
                                          'type' => 'conditions',
                                          'definition' => 'diagnosis',
                                          'hard_status' => false,
                                          'negation' => false,
                                          'field_values' => {
                                            'ORDINAL' => {
                                              'type' => 'CD',
                                              'code_list_id' => '1.16.17.18',
                                              'title' => 'Principal'
                                            }
                                          },
                                          'source_data_criteria' => 'DiagnosisActivePregnancy' } } }
      hqmf_document { hqmf_doc }
    end
    trait :no_diagnosis do
      hqmf_doc = { 'source_data_criteria' => { 'PhysicalExamFindingBmiPercentile' =>
                                               { 'title' => 'BMI percentile',
                                                 'description' => 'Physical Exam, Finding=> BMI percentile',
                                                 'standard_category' => 'physical_exam',
                                                 'qds_data_type' => 'physical_exam',
                                                 'code_list_id' => '1.7.8.9',
                                                 'type' => 'physical_exams',
                                                 'definition' => 'physical_exam',
                                                 'hard_status' => false,
                                                 'negation' => false,
                                                 'source_data_criteria' => 'PhysicalExamFindingBmiPercentile' } },
                   'data_criteria' => { 'PhysicalExamFindingBmiPercentile_precondition_8' =>
                                        { 'title' => 'BMI percentile',
                                          'description' => 'Physical Exam, Finding=> BMI percentile',
                                          'standard_category' => 'physical_exam',
                                          'qds_data_type' => 'physical_exam',
                                          'code_list_id' => '1.7.8.9',
                                          'type' => 'physical_exams',
                                          'definition' => 'physical_exam',
                                          'hard_status' => false,
                                          'negation' => false,
                                          'source_data_criteria' => 'PhysicalExamFindingBmiPercentile',
                                          'temporal_references' => [
                                            { 'type' => 'DURING',
                                              'reference' => 'MeasurePeriod' }
                                          ] } } }
      hqmf_document { hqmf_doc }
    end

    factory :measure_with_diagnosis, traits: [:diagnosis]
    factory :measure_without_diagnosis, traits: [:no_diagnosis]

    factory :static_measure do
      name 'Static Measure'
      cms_id 'CMS1234'
      hqmf_id 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE'
      hqmf_set_id 'C621C7B6-EB1F-11E7-8C3F-9A214CF093AE'
      map_fn "function() {\n        var patient = this;\n        var effective_date = <%= effective_date %>;\n        var enable_logging = <%= enable_logging %>;\n        var enable_rationale = <%= enable_rationale %>;\n\n        hqmfjs = {}\n        <%= init_js_frameworks %>\n        \n        \n      var patient_api = new hQuery.Patient(patient);\n\n      \n        // #########################\n        // ##### DATA ELEMENTS #####\n        // #########################\n\n        OidDictionary = <%= oid_dictionary %>;\n        \n        // Measure variables\nvar MeasurePeriod = {\n  \"low\": new TS(\"201201010000\", null, true),\n  \"high\": new TS(\"201212312359\", null, true)\n}\nhqmfjs.MeasurePeriod = function(patient) {\n  return [new hQuery.CodedEntry(\n    {\n      \"start_time\": MeasurePeriod.low.asDate().getTime()/1000,\n      \"end_time\": MeasurePeriod.high.asDate().getTime()/1000,\n      \"codes\": {}\n    }\n  )];\n}\nif (typeof effective_date === 'number') {\n  MeasurePeriod.high.date = new Date(1000*effective_date);\n  // add one minute before pulling off the year.  This turns 12-31-2012 23:59 into 1-1-2013 00:00 => 1-1-2012 00:00\n  MeasurePeriod.low.date = new Date(1000*(effective_date+60));\n  MeasurePeriod.low.date.setFullYear(MeasurePeriod.low.date.getFullYear()-1);\n}\n\n// Data critera\nhqmfjs.OccurrenceAPregnancy1 = function(patient, initialSpecificContext) {\n  var events = patient.allProblems();\n  events.specific_occurrence = 'OccurrenceAPregnancy1'\n  events = events.withStatuses([\"active\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.5.6.7\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  events.specificContext=new hqmf.SpecificOccurrence(Row.buildForDataCriteria(events.specific_occurrence, events))\n  return events;\n}\n\nhqmfjs.DiagnosisActivePregnancy = function(patient, initialSpecificContext) {\n  var events = patient.allProblems();\n  events = events.withStatuses([\"active\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.5.6.7\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  hqmf.SpecificsManager.setIfNull(events);\n  return events;\n}\n\nhqmfjs.PatientCharacteristicSexOncAdministrativeSex = function(patient, initialSpecificContext) {\nvar value = patient.gender() || null;\nmatching = matchingValue(value, new CD(\"F\", \"Administrative Sex\"));\nmatching.specificContext=hqmf.SpecificsManager.identity();\nreturn matching;\n\n}\n\nhqmfjs.PatientCharacteristicRaceRace = function(patient, initialSpecificContext) {\nvar value = patient.race() || null;\nmatching = matchingValue(value, null);\nmatching.specificContext=hqmf.SpecificsManager.identity();\nreturn matching;\n\n}\n\nhqmfjs.PatientCharacteristicEthnicityEthnicity = function(patient, initialSpecificContext) {\nvar value = patient.ethnicity() || null;\nmatching = matchingValue(value, null);\nmatching.specificContext=hqmf.SpecificsManager.identity();\nreturn matching;\n\n}\n\nhqmfjs.PatientCharacteristicPayerPayer = function(patient, initialSpecificContext) {\nvar value = patient.payer() || null;\nmatching = matchingValue(value, null);\nmatching.specificContext=hqmf.SpecificsManager.identity();\nreturn matching;\n\n}\n\nhqmfjs.OccurrenceAPregnancy1_precondition_4 = function(patient, initialSpecificContext) {\n  var events = patient.allProblems();\n  events.specific_occurrence = 'OccurrenceAPregnancy1'\n  events = events.withStatuses([\"active\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.5.6.7\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = SBE(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.OccurrenceAPregnancy1_precondition_2 = function(patient, initialSpecificContext) {\n  var events = patient.allProblems();\n  events.specific_occurrence = 'OccurrenceAPregnancy1'\n  events = events.withStatuses([\"active\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.5.6.7\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = EBS(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.PhysicalExamFindingBmiPercentile_precondition_8 = function(patient, initialSpecificContext) {\n  var events = patient.procedureResults();\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.7.8.9\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.PhysicalExamFindingHeight_precondition_10 = function(patient, initialSpecificContext) {\n  var events = patient.procedureResults();\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.8.9.10\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.PhysicalExamFindingWeight_precondition_12 = function(patient, initialSpecificContext) {\n  var events = patient.procedureResults();\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.9.10.11\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.InterventionPerformedCounselingForNutrition_precondition_17 = function(patient, initialSpecificContext) {\n  var events = patient.allProcedures();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.10.11.12\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.InterventionPerformedCounselingForPhysicalActivity_precondition_20 = function(patient, initialSpecificContext) {\n  var events = patient.allProcedures();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.11.12.13\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_23 = function(patient, initialSpecificContext) {\nvar value = patient.birthtime() || null;\nvar events = [value];\nevents = SBS(events, hqmfjs.MeasurePeriod(patient), new IVL_PQ(new PQ(3, \"a\", true), null));\nevents.specificContext=hqmf.SpecificsManager.identity();\nreturn events;\n\n}\n\nhqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_25 = function(patient, initialSpecificContext) {\nvar value = patient.birthtime() || null;\nvar events = [value];\nevents = SBS(events, hqmfjs.MeasurePeriod(patient), new IVL_PQ(null, new PQ(17, \"a\", true)));\nevents.specificContext=hqmf.SpecificsManager.identity();\nreturn events;\n\n}\n\nhqmfjs.EncounterPerformedFaceToFaceInteraction_precondition_27 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.4.5.6\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedOfficeVisit_precondition_29 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.3.4.5\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_31 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.12.13.14\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_33 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.13.14.15\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_35 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.14.15.16\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_37 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.15.16.17\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedHomeHealthcareServices_precondition_39 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.6.7.8\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_44 = function(patient, initialSpecificContext) {\nvar value = patient.birthtime() || null;\nvar events = [value];\nevents = SBS(events, hqmfjs.MeasurePeriod(patient), new IVL_PQ(new PQ(3, \"a\", true), null));\nevents.specificContext=hqmf.SpecificsManager.identity();\nreturn events;\n\n}\n\nhqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_46 = function(patient, initialSpecificContext) {\nvar value = patient.birthtime() || null;\nvar events = [value];\nevents = SBS(events, hqmfjs.MeasurePeriod(patient), new IVL_PQ(null, new PQ(11, \"a\", true)));\nevents.specificContext=hqmf.SpecificsManager.identity();\nreturn events;\n\n}\n\nhqmfjs.EncounterPerformedFaceToFaceInteraction_precondition_48 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.4.5.6\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedOfficeVisit_precondition_50 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.3.4.5\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_52 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.12.13.14\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_54 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.13.14.15\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_56 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.14.15.16\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_58 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.15.16.17\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedHomeHealthcareServices_precondition_60 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.6.7.8\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_65 = function(patient, initialSpecificContext) {\nvar value = patient.birthtime() || null;\nvar events = [value];\nevents = SBS(events, hqmfjs.MeasurePeriod(patient), new IVL_PQ(new PQ(12, \"a\", true), null));\nevents.specificContext=hqmf.SpecificsManager.identity();\nreturn events;\n\n}\n\nhqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_67 = function(patient, initialSpecificContext) {\nvar value = patient.birthtime() || null;\nvar events = [value];\nevents = SBS(events, hqmfjs.MeasurePeriod(patient), new IVL_PQ(null, new PQ(17, \"a\", true)));\nevents.specificContext=hqmf.SpecificsManager.identity();\nreturn events;\n\n}\n\nhqmfjs.EncounterPerformedFaceToFaceInteraction_precondition_69 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.4.5.6\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedOfficeVisit_precondition_71 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.3.4.5\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_73 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.12.13.14\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_75 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.13.14.15\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_77 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.14.15.16\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_79 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.15.16.17\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\nhqmfjs.EncounterPerformedHomeHealthcareServices_precondition_81 = function(patient, initialSpecificContext) {\n  var events = patient.encounters();\n  events = events.withStatuses([\"performed\"]);\n  events = events.withoutNegation();\n  var codes = getCodes(\"1.6.7.8\");\n  var start = null;\n  var end = null;\n  events = events.match(codes, start, end, true);\n\n  if (events.length > 0) events = DURING(events, hqmfjs.MeasurePeriod(patient));\n  else events.specificContext=hqmf.SpecificsManager.empty();\n  return events;\n}\n\n\n\n        // #########################\n        // ##### MEASURE LOGIC #####\n        // #########################\n        \n        hqmfjs.initializeSpecifics = function(patient_api, hqmfjs) { hqmf.SpecificsManager.initialize(patient_api,hqmfjs,{\"id\":\"OccurrenceAPregnancy1\",\"type\":\"DIAGNOSIS_ACTIVE_PREGNANCY\",\"function\":\"OccurrenceAPregnancy1\"}) }\n\n        // INITIAL PATIENT POPULATION\n        hqmfjs.IPP = function(patient, initialSpecificContext) {\n  return allTrue('IPP',  \n    allTrue('43',     hqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_23(patient, initialSpecificContext),     hqmfjs.PatientCharacteristicBirthdateBirthDate_precondition_25(patient, initialSpecificContext),    \n      atLeastOneTrue('41',       hqmfjs.EncounterPerformedFaceToFaceInteraction_precondition_27(patient, initialSpecificContext),       hqmfjs.EncounterPerformedOfficeVisit_precondition_29(patient, initialSpecificContext),       hqmfjs.EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_31(patient, initialSpecificContext),       hqmfjs.EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_33(patient, initialSpecificContext),       hqmfjs.EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_35(patient, initialSpecificContext),       hqmfjs.EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_37(patient, initialSpecificContext),       hqmfjs.EncounterPerformedHomeHealthcareServices_precondition_39(patient, initialSpecificContext)\n      )\n    )\n  );\n};\n\n\n        // DENOMINATOR\n        hqmfjs.DENOM = function(patient) { return new Boolean(true); }\n        // NUMERATOR\n        hqmfjs.NUMER = function(patient, initialSpecificContext) {\n  return allTrue('NUMER',  \n    allTrue('16',    \n      allTrue('14',       hqmfjs.PhysicalExamFindingBmiPercentile_precondition_8(patient, initialSpecificContext),       hqmfjs.PhysicalExamFindingHeight_precondition_10(patient, initialSpecificContext),       hqmfjs.PhysicalExamFindingWeight_precondition_12(patient, initialSpecificContext)\n      )\n    )\n  );\n};\n\n\n        hqmfjs.DENEX = function(patient, initialSpecificContext) {\n  return atLeastOneTrue('DENEX',  \n    allTrue('7',     hqmfjs.OccurrenceAPregnancy1_precondition_4(patient, initialSpecificContext),    \n      allFalse('6',       hqmfjs.OccurrenceAPregnancy1_precondition_2(patient, initialSpecificContext)\n      )\n    )\n  );\n};\n\n\n        hqmfjs.DENEXCEP = function(patient) { return new Boolean(false); }\n        // CV\n        hqmfjs.MSRPOPL = function(patient) { return new Boolean(false); }\n        hqmfjs.OBSERV = function(patient) { return new Boolean(false); }\n        \n      \n      var occurrenceId = null;\n\n      hqmfjs.initializeSpecifics(patient_api, hqmfjs)\n      \n      var population = function() {\n        return executeIfAvailable(hqmfjs.IPP, patient_api);\n      }\n      var denominator = function() {\n        return executeIfAvailable(hqmfjs.DENOM, patient_api);\n      }\n      var numerator = function() {\n        return executeIfAvailable(hqmfjs.NUMER, patient_api);\n      }\n      var exclusion = function() {\n        return executeIfAvailable(hqmfjs.DENEX, patient_api);\n      }\n      var denexcep = function() {\n        return executeIfAvailable(hqmfjs.DENEXCEP, patient_api);\n      }\n      var msrpopl = function() {\n        return executeIfAvailable(hqmfjs.MSRPOPL, patient_api);\n      }\n      var observ = function(specific_context) {\n        \n        var observFunc = hqmfjs.OBSERV\n        if (typeof(observFunc)==='function')\n          return observFunc(patient_api, specific_context);\n        else\n          return [];\n      }\n      \n      var executeIfAvailable = function(optionalFunction, patient_api) {\n        if (typeof(optionalFunction)==='function') {\n          result = optionalFunction(patient_api);\n          \n          return result;\n        } else {\n          return false;\n        }\n      }\n\n      \n      if (typeof Logger != 'undefined') {\n        // clear out logger\n        Logger.logger = [];\n        Logger.rationale={};\n      \n        // turn on logging if it is enabled\n        if (enable_logging || enable_rationale) {\n          injectLogger(hqmfjs, enable_logging, enable_rationale);\n        }\n      }\n\n      map(patient, population, denominator, numerator, exclusion, denexcep, msrpopl, observ, occurrenceId,false);\n      \n      };\n      "
      continuous_variable false
      category 'static'
      type 'ep'
      episode_of_care true
      sub_id 'a'
      hqmf_doc = {
        {
          "id": "40280382-6258-7581-0162-92877E281530",
          "nqf_id": "0043",
          "hqmf_id": "40280382-6258-7581-0162-92877E281530",
          "hqmf_set_id": "59657B9B-01BF-4979-A090-8534DA1D0516",
          "hqmf_version_number": 7,
          "cms_id": "CMS127v7",
          "name": "Pneumococcal Vaccination Status for Older Adults",
          "description": "Percentage of patients 65 years of age and older who have ever received a pneumococcal vaccine",
          "type": "ep",
          "category": "General Practice Adult",
          "source_data_criteria": {
            "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b_source": {
              "title": "PneumococcalVaccineAdministered",
              "description": "Procedure, Performed: PneumococcalVaccineAdministered",
              "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1034",
              "type": "procedures",
              "definition": "procedure",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b_source",
              "variable": false
            },
            "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344_source": {
              "title": "Payer",
              "description": "Patient Characteristic Payer: Payer",
              "code_list_id": "2.16.840.1.114222.4.11.3591",
              "property": "payer",
              "type": "characteristic",
              "definition": "patient_characteristic_payer",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344_source",
              "variable": false,
              "inline_code_list": {
                "Source of Payment Typology": [
                  "1",
                  "11",
                  "111",
                  "112",
                  "113",
                  "119",
                  "12",
                  "121",
                  "122",
                  "123",
                  "129",
                  "13",
                  "14",
                  "19",
                  "191",
                  "2",
                  "21",
                  "211",
                  "212",
                  "213",
                  "219",
                  "22",
                  "23",
                  "24",
                  "25",
                  "26",
                  "29",
                  "291",
                  "299",
                  "3",
                  "31",
                  "311",
                  "3111",
                  "3112",
                  "3113",
                  "3114",
                  "3115",
                  "3116",
                  "3119",
                  "312",
                  "3121",
                  "3122",
                  "3123",
                  "313",
                  "32",
                  "321",
                  "3211",
                  "3212",
                  "32121",
                  "32122",
                  "32123",
                  "32124",
                  "32125",
                  "32126",
                  "32127",
                  "32128",
                  "322",
                  "3221",
                  "3222",
                  "3223",
                  "3229",
                  "33",
                  "331",
                  "332",
                  "333",
                  "334",
                  "34",
                  "341",
                  "342",
                  "343",
                  "349",
                  "35",
                  "36",
                  "361",
                  "362",
                  "369",
                  "37",
                  "371",
                  "3711",
                  "3712",
                  "3713",
                  "372",
                  "379",
                  "38",
                  "381",
                  "3811",
                  "3812",
                  "3813",
                  "3819",
                  "382",
                  "389",
                  "39",
                  "391",
                  "4",
                  "41",
                  "42",
                  "43",
                  "44",
                  "5",
                  "51",
                  "511",
                  "512",
                  "513",
                  "514",
                  "515",
                  "516",
                  "517",
                  "519",
                  "52",
                  "521",
                  "522",
                  "523",
                  "524",
                  "529",
                  "53",
                  "54",
                  "55",
                  "56",
                  "561",
                  "562",
                  "59",
                  "6",
                  "61",
                  "611",
                  "612",
                  "613",
                  "614",
                  "619",
                  "62",
                  "621",
                  "622",
                  "623",
                  "629",
                  "7",
                  "71",
                  "72",
                  "73",
                  "79",
                  "8",
                  "81",
                  "82",
                  "821",
                  "822",
                  "823",
                  "83",
                  "84",
                  "85",
                  "89",
                  "9",
                  "91",
                  "92",
                  "93",
                  "94",
                  "95",
                  "951",
                  "953",
                  "954",
                  "959",
                  "96",
                  "97",
                  "98",
                  "99",
                  "9999"
                ]
              }
            },
            "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d_source": {
              "title": "ONCAdministrativeSex",
              "description": "Patient Characteristic Sex: ONCAdministrativeSex",
              "code_list_id": "2.16.840.1.113762.1.4.1",
              "property": "gender",
              "type": "characteristic",
              "definition": "patient_characteristic_gender",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d_source",
              "variable": false,
              "value": {
                "type": "CD",
                "system": "Administrative Sex",
                "code": "F"
              }
            },
            "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b_source": {
              "title": "CareServicesinLong-TermResidentialFacility",
              "description": "Encounter, Performed: CareServicesinLong-TermResidentialFacility",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1014",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b_source",
              "variable": false
            },
            "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3_source": {
              "title": "EncounterInpatient",
              "description": "Encounter, Performed: EncounterInpatient",
              "code_list_id": "2.16.840.1.113883.3.666.5.307",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3_source",
              "variable": false
            },
            "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e_source": {
              "title": "PreventiveCareServices-EstablishedOfficeVisit18andUp",
              "description": "Encounter, Performed: PreventiveCareServices-EstablishedOfficeVisit18andUp",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1025",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e_source",
              "variable": false
            },
            "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30_source": {
              "title": "AnnualWellnessVisit",
              "description": "Encounter, Performed: AnnualWellnessVisit",
              "code_list_id": "2.16.840.1.113883.3.526.3.1240",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30_source",
              "variable": false
            },
            "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098_source": {
              "title": "Hospicecareambulatory",
              "description": "Intervention, Order: Hospicecareambulatory",
              "code_list_id": "2.16.840.1.113762.1.4.1108.15",
              "type": "interventions",
              "definition": "intervention",
              "status": "ordered",
              "hard_status": true,
              "negation": false,
              "source_data_criteria": "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
              "variable": false
            },
            "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098_source": {
              "title": "Hospicecareambulatory",
              "description": "Intervention, Performed: Hospicecareambulatory",
              "code_list_id": "2.16.840.1.113762.1.4.1108.15",
              "type": "interventions",
              "definition": "intervention",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
              "variable": false
            },
            "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271_source": {
              "title": "Ethnicity",
              "description": "Patient Characteristic Ethnicity: Ethnicity",
              "code_list_id": "2.16.840.1.114222.4.11.837",
              "property": "ethnicity",
              "type": "characteristic",
              "definition": "patient_characteristic_ethnicity",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271_source",
              "variable": false,
              "inline_code_list": {
                "CDC Race": [
                  "2135-2",
                  "2186-5"
                ]
              }
            },
            "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968_source": {
              "title": "DischargeServices-NursingFacility",
              "description": "Encounter, Performed: DischargeServices-NursingFacility",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.11.1065",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968_source",
              "variable": false
            },
            "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32_source": {
              "title": "HomeHealthcareServices",
              "description": "Encounter, Performed: HomeHealthcareServices",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1016",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32_source",
              "variable": false
            },
            "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113_source": {
              "title": "PneumococcalVaccine",
              "description": "Immunization, Administered: PneumococcalVaccine",
              "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1027",
              "type": "immunizations",
              "definition": "immunization",
              "status": "administered",
              "hard_status": true,
              "negation": false,
              "source_data_criteria": "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113_source",
              "variable": false
            },
            "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7_source": {
              "title": "Race",
              "description": "Patient Characteristic Race: Race",
              "code_list_id": "2.16.840.1.114222.4.11.836",
              "property": "race",
              "type": "characteristic",
              "definition": "patient_characteristic_race",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7_source",
              "variable": false,
              "inline_code_list": {
                "CDC Race": [
                  "1002-5",
                  "2028-9",
                  "2054-5",
                  "2076-8",
                  "2106-3",
                  "2131-1"
                ]
              }
            },
            "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e_source": {
              "title": "NursingFacilityVisit",
              "description": "Encounter, Performed: NursingFacilityVisit",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1012",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e_source",
              "variable": false
            },
            "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d_source": {
              "title": "OfficeVisit",
              "description": "Encounter, Performed: OfficeVisit",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1001",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d_source",
              "variable": false
            },
            "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f_source": {
              "title": "PreventiveCareServices-InitialOfficeVisit18andUp",
              "description": "Encounter, Performed: PreventiveCareServices-InitialOfficeVisit18andUp",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1023",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f_source",
              "variable": false
            }
          },
         "population_criteria": {
             "IPP": {
              "conjunction?": true,
              "type": "IPP",
              "hqmf_id": "AD7E66D5-D06C-4079-8086-8B2978CA1AEF",
              "preconditions": [
                {
                  "id": 2,
                  "preconditions": [
                    {
                      "id": 1,
                      "reference": "PneumococcalVaccinationStatusforOlderAdults__Initial_Population__71939976_0545_4990_B370_4081C4892B6B"
                    }
                  ],
                  "conjunction_code": "allTrue"
                }
              ]
            },
            "DENOM": {
              "conjunction?": true,
              "type": "DENOM",
              "hqmf_id": "FC166E13-A380-466E-8E38-2E86261ADB21",
              "preconditions": [
                {
                  "id": 4,
                  "preconditions": [
                    {
                      "id": 3,
                      "reference": "PneumococcalVaccinationStatusforOlderAdults__Denominator__71939976_0545_4990_B370_4081C4892B6B"
                    }
                  ],
                  "conjunction_code": "allTrue"
                }
              ]
            },
            "NUMER": {
              "conjunction?": true,
              "type": "NUMER",
              "hqmf_id": "BE0E99DE-0998-4E13-AEE7-8012513CF47E",
              "preconditions": [
                {
                  "id": 6,
                  "preconditions": [
                    {
                      "id": 5,
                      "reference": "PneumococcalVaccinationStatusforOlderAdults__Numerator__71939976_0545_4990_B370_4081C4892B6B"
                    }
                  ],
                  "conjunction_code": "allTrue"
                }
              ]
            },
            "DENEX": {
              "conjunction?": true,
              "type": "DENEX",
              "hqmf_id": "A791271E-6A92-406C-B67B-C6F6175F3FE7",
              "preconditions": [
                {
                  "id": 8,
                  "preconditions": [
                    {
                      "id": 7,
                      "reference": "PneumococcalVaccinationStatusforOlderAdults__Denominator_Exclusions__71939976_0545_4990_B370_4081C4892B6B"
                    }
                  ],
                  "conjunction_code": "atLeastOneTrue"
                }
              ]
            }
          },
          "data_criteria": {
            "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b": {
              "title": "PneumococcalVaccineAdministered",
              "description": "Procedure, Performed: PneumococcalVaccineAdministered",
              "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1034",
              "type": "procedures",
              "definition": "procedure",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b_source",
              "variable": false
            },
            "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344": {
              "title": "Payer",
              "description": "Patient Characteristic Payer: Payer",
              "code_list_id": "2.16.840.1.114222.4.11.3591",
              "property": "payer",
              "type": "characteristic",
              "definition": "patient_characteristic_payer",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344_source",
              "variable": false,
              "inline_code_list": {
                "Source of Payment Typology": [
                  "1",
                  "11",
                  "111",
                  "112",
                  "113",
                  "119",
                  "12",
                  "121",
                  "122",
                  "123",
                  "129",
                  "13",
                  "14",
                  "19",
                  "191",
                  "2",
                  "21",
                  "211",
                  "212",
                  "213",
                  "219",
                  "22",
                  "23",
                  "24",
                  "25",
                  "26",
                  "29",
                  "291",
                  "299",
                  "3",
                  "31",
                  "311",
                  "3111",
                  "3112",
                  "3113",
                  "3114",
                  "3115",
                  "3116",
                  "3119",
                  "312",
                  "3121",
                  "3122",
                  "3123",
                  "313",
                  "32",
                  "321",
                  "3211",
                  "3212",
                  "32121",
                  "32122",
                  "32123",
                  "32124",
                  "32125",
                  "32126",
                  "32127",
                  "32128",
                  "322",
                  "3221",
                  "3222",
                  "3223",
                  "3229",
                  "33",
                  "331",
                  "332",
                  "333",
                  "334",
                  "34",
                  "341",
                  "342",
                  "343",
                  "349",
                  "35",
                  "36",
                  "361",
                  "362",
                  "369",
                  "37",
                  "371",
                  "3711",
                  "3712",
                  "3713",
                  "372",
                  "379",
                  "38",
                  "381",
                  "3811",
                  "3812",
                  "3813",
                  "3819",
                  "382",
                  "389",
                  "39",
                  "391",
                  "4",
                  "41",
                  "42",
                  "43",
                  "44",
                  "5",
                  "51",
                  "511",
                  "512",
                  "513",
                  "514",
                  "515",
                  "516",
                  "517",
                  "519",
                  "52",
                  "521",
                  "522",
                  "523",
                  "524",
                  "529",
                  "53",
                  "54",
                  "55",
                  "56",
                  "561",
                  "562",
                  "59",
                  "6",
                  "61",
                  "611",
                  "612",
                  "613",
                  "614",
                  "619",
                  "62",
                  "621",
                  "622",
                  "623",
                  "629",
                  "7",
                  "71",
                  "72",
                  "73",
                  "79",
                  "8",
                  "81",
                  "82",
                  "821",
                  "822",
                  "823",
                  "83",
                  "84",
                  "85",
                  "89",
                  "9",
                  "91",
                  "92",
                  "93",
                  "94",
                  "95",
                  "951",
                  "953",
                  "954",
                  "959",
                  "96",
                  "97",
                  "98",
                  "99",
                  "9999"
                ]
              }
            },
            "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d": {
              "title": "ONCAdministrativeSex",
              "description": "Patient Characteristic Sex: ONCAdministrativeSex",
              "code_list_id": "2.16.840.1.113762.1.4.1",
              "property": "gender",
              "type": "characteristic",
              "definition": "patient_characteristic_gender",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d_source",
              "variable": false,
              "value": {
                "type": "CD",
                "system": "Administrative Sex",
                "code": "F"
              }
            },
            "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b": {
              "title": "CareServicesinLong-TermResidentialFacility",
              "description": "Encounter, Performed: CareServicesinLong-TermResidentialFacility",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1014",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b_source",
              "variable": false
            },
            "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3": {
              "title": "EncounterInpatient",
              "description": "Encounter, Performed: EncounterInpatient",
              "code_list_id": "2.16.840.1.113883.3.666.5.307",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3_source",
              "variable": false
            },
            "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e": {
              "title": "PreventiveCareServices-EstablishedOfficeVisit18andUp",
              "description": "Encounter, Performed: PreventiveCareServices-EstablishedOfficeVisit18andUp",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1025",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e_source",
              "variable": false
            },
            "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30": {
              "title": "AnnualWellnessVisit",
              "description": "Encounter, Performed: AnnualWellnessVisit",
              "code_list_id": "2.16.840.1.113883.3.526.3.1240",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30_source",
              "variable": false
            },
            "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098": {
              "title": "Hospicecareambulatory",
              "description": "Intervention, Order: Hospicecareambulatory",
              "code_list_id": "2.16.840.1.113762.1.4.1108.15",
              "type": "interventions",
              "definition": "intervention",
              "status": "ordered",
              "hard_status": true,
              "negation": false,
              "source_data_criteria": "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
              "variable": false
            },
            "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098": {
              "title": "Hospicecareambulatory",
              "description": "Intervention, Performed: Hospicecareambulatory",
              "code_list_id": "2.16.840.1.113762.1.4.1108.15",
              "type": "interventions",
              "definition": "intervention",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
              "variable": false
            },
            "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271": {
              "title": "Ethnicity",
              "description": "Patient Characteristic Ethnicity: Ethnicity",
              "code_list_id": "2.16.840.1.114222.4.11.837",
              "property": "ethnicity",
              "type": "characteristic",
              "definition": "patient_characteristic_ethnicity",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271_source",
              "variable": false,
              "inline_code_list": {
                "CDC Race": [
                  "2135-2",
                  "2186-5"
                ]
              }
            },
            "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968": {
              "title": "DischargeServices-NursingFacility",
              "description": "Encounter, Performed: DischargeServices-NursingFacility",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.11.1065",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968_source",
              "variable": false
            },
            "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32": {
              "title": "HomeHealthcareServices",
              "description": "Encounter, Performed: HomeHealthcareServices",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1016",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32_source",
              "variable": false
            },
            "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113": {
              "title": "PneumococcalVaccine",
              "description": "Immunization, Administered: PneumococcalVaccine",
              "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1027",
              "type": "immunizations",
              "definition": "immunization",
              "status": "administered",
              "hard_status": true,
              "negation": false,
              "source_data_criteria": "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113_source",
              "variable": false
            },
            "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7": {
              "title": "Race",
              "description": "Patient Characteristic Race: Race",
              "code_list_id": "2.16.840.1.114222.4.11.836",
              "property": "race",
              "type": "characteristic",
              "definition": "patient_characteristic_race",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7_source",
              "variable": false,
              "inline_code_list": {
                "CDC Race": [
                  "1002-5",
                  "2028-9",
                  "2054-5",
                  "2076-8",
                  "2106-3",
                  "2131-1"
                ]
              }
            },
            "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e": {
              "title": "NursingFacilityVisit",
              "description": "Encounter, Performed: NursingFacilityVisit",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1012",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e_source",
              "variable": false
            },
            "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d": {
              "title": "OfficeVisit",
              "description": "Encounter, Performed: OfficeVisit",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1001",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d_source",
              "variable": false
            },
            "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f": {
              "title": "PreventiveCareServices-InitialOfficeVisit18andUp",
              "description": "Encounter, Performed: PreventiveCareServices-InitialOfficeVisit18andUp",
              "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1023",
              "type": "encounters",
              "definition": "encounter",
              "status": "performed",
              "hard_status": false,
              "negation": false,
              "source_data_criteria": "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f_source",
              "variable": false
            }
          },
          "attributes": [
            {
              "code": "OTH",
              "value": "127",
              "name": "eCQM Identifier (Measure Authoring Tool)",
              "code_obj": {
                "type": "CD",
                "null_flavor": "OTH",
                "original_text": "eCQM Identifier (Measure Authoring Tool)"
              },
              "value_obj": {
                "type": "ED",
                "value": "127",
                "media_type": "text/plain"
              }
            },
            {
              "code": "OTH",
              "value": "Not Applicable",
              "name": "NQF Number",
              "code_obj": {
                "type": "CD",
                "null_flavor": "OTH",
                "original_text": "NQF Number"
              },
              "value_obj": {
                "type": "ED",
                "value": "Not Applicable",
                "media_type": "text/plain"
              }
            },
            {
              "code": "COPY",
              "value": "This Physician Performance Measure (Measure) and related data specifications were developed by the National Committee for Quality Assurance (NCQA). NCQA is not responsible for any use of the Measure. NCQA makes no representations, warranties, or endorsement about the quality of any organization or physician that uses or reports performance measures and NCQA has no liability to anyone who relies on such measures or specifications. NCQA holds a copyright in the Measure. The Measure can be reproduced and distributed, without modification, for noncommercial purposes (eg, use by healthcare providers in connection with their practices) without obtaining approval from NCQA. Commercial use is defined as the sale, licensing, or distribution of the Measure for commercial gain, or incorporation of the Measure into a product or service that is sold, licensed or distributed for commercial gain. All commercial uses or requests for modification must be approved by NCQA and are subject to a license at the discretion of NCQA. (C) 2012-2017 National Committee for Quality Assurance. All Rights Reserved. \n\nLimited proprietary coding is contained in the Measure specifications for user convenience. Users of proprietary code sets should obtain all necessary licenses from the owners of the code sets. NCQA disclaims all liability for use or accuracy of any third party codes contained in the specifications.\n\nCPT(R) contained in the Measure specifications is copyright 2004-2017 American Medical Association. LOINC(R) copyright 2004-2017 Regenstrief Institute, Inc. This material contains SNOMED Clinical Terms(R) (SNOMED CT[R] ) copyright 2004-2017 International Health Terminology Standards Development Organisation. ICD-10 copyright 2017 World Health Organization. All Rights Reserved.",
              "name": "Copyright",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "COPY",
                "title": "Copyright"
              },
              "value_obj": {
                "type": "ED",
                "value": "This Physician Performance Measure (Measure) and related data specifications were developed by the National Committee for Quality Assurance (NCQA). NCQA is not responsible for any use of the Measure. NCQA makes no representations, warranties, or endorsement about the quality of any organization or physician that uses or reports performance measures and NCQA has no liability to anyone who relies on such measures or specifications. NCQA holds a copyright in the Measure. The Measure can be reproduced and distributed, without modification, for noncommercial purposes (eg, use by healthcare providers in connection with their practices) without obtaining approval from NCQA. Commercial use is defined as the sale, licensing, or distribution of the Measure for commercial gain, or incorporation of the Measure into a product or service that is sold, licensed or distributed for commercial gain. All commercial uses or requests for modification must be approved by NCQA and are subject to a license at the discretion of NCQA. (C) 2012-2017 National Committee for Quality Assurance. All Rights Reserved. \n\nLimited proprietary coding is contained in the Measure specifications for user convenience. Users of proprietary code sets should obtain all necessary licenses from the owners of the code sets. NCQA disclaims all liability for use or accuracy of any third party codes contained in the specifications.\n\nCPT(R) contained in the Measure specifications is copyright 2004-2017 American Medical Association. LOINC(R) copyright 2004-2017 Regenstrief Institute, Inc. This material contains SNOMED Clinical Terms(R) (SNOMED CT[R] ) copyright 2004-2017 International Health Terminology Standards Development Organisation. ICD-10 copyright 2017 World Health Organization. All Rights Reserved.",
                "media_type": "text/plain"
              }
            },
            {
              "code": "DISC",
              "value": "The performance Measure is not a clinical guideline and does not establish a standard of medical care, and has not been tested for all potential applications. THE MEASURE AND SPECIFICATIONS ARE PROVIDED \"AS IS\" WITHOUT WARRANTY OF ANY KIND.\n \nDue to technical limitations, registered trademarks are indicated by (R) or [R] and unregistered trademarks are indicated by (TM) or [TM].",
              "name": "Disclaimer",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "DISC",
                "title": "Disclaimer"
              },
              "value_obj": {
                "type": "ED",
                "value": "The performance Measure is not a clinical guideline and does not establish a standard of medical care, and has not been tested for all potential applications. THE MEASURE AND SPECIFICATIONS ARE PROVIDED \"AS IS\" WITHOUT WARRANTY OF ANY KIND.\n \nDue to technical limitations, registered trademarks are indicated by (R) or [R] and unregistered trademarks are indicated by (TM) or [TM].",
                "media_type": "text/plain"
              }
            },
            {
              "code": "MSRSCORE",
              "name": "Measure Scoring",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "MSRSCORE",
                "title": "Measure Scoring"
              },
              "value_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.1.11.20367",
                "code": "PROPOR",
                "title": "Proportion"
              }
            },
            {
              "code": "MSRTYPE",
              "name": "Measure Type",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "MSRTYPE",
                "title": "Measure Type"
              },
              "value_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.1.11.20368",
                "code": "PROCESS",
                "title": "PROCESS"
              }
            },
            {
              "code": "STRAT",
              "value": "None",
              "name": "Stratification",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "STRAT",
                "title": "Stratification"
              },
              "value_obj": {
                "type": "ED",
                "value": "None",
                "media_type": "text/plain"
              }
            },
            {
              "code": "MSRADJ",
              "value": "None",
              "name": "Risk Adjustment",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "MSRADJ",
                "title": "Risk Adjustment"
              },
              "value_obj": {
                "type": "ED",
                "value": "None",
                "media_type": "text/plain"
              }
            },
            {
              "code": "MSRAGG",
              "value": "None",
              "name": "Rate Aggregation",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "MSRAGG",
                "title": "Rate Aggregation"
              },
              "value_obj": {
                "type": "ED",
                "value": "None",
                "media_type": "text/plain"
              }
            },
            {
              "code": "RAT",
              "value": "Pneumonia is a common cause of illness and death in the elderly and persons with certain underlying conditions such as heart failure, diabetes, cystic fibrosis, asthma, sickle cell anemia, or chronic obstructive pulmonary disease (NHLBI, 2011). In 1998, an estimated 3,400 adults aged > 65 years died as a result of invasive pneumococcal disease (IPD) (CDC, 2003).\n\nAmong the 91.5 million US adults aged > 50 years, 29,500 cases of IPD, 502,600 cases of nonbacteremic pneumococcal pneumonia and 25,400 pneumococcal-related deaths are estimated to occur yearly; annual direct and indirect costs are estimated to total $3.7 billion and $1.8 billion, respectively. Pneumococcal disease remains a substantial burden among older US adults, despite increased coverage with 23-valent pneumococcal polysaccharide vaccine, (PPV23) and indirect benefits afforded by PCV7 vaccination of young children (Weycker, et al., 2011).\n\nVaccination has been found to be effective against bacteremic cases (OR: 0.34; 95% CI: 0.27-0.66) as well as nonbacteremic cases (OR: 0.58; 95% CI: 0.39-0.86). Vaccine effectiveness was highest against bacteremic infections caused by vaccine types (OR: 0.24; 95% CI: 0.09-0.66) (Vila-Corcoles, et al., 2009).",
              "name": "Rationale",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "RAT",
                "title": "Rationale"
              },
              "value_obj": {
                "type": "ED",
                "value": "Pneumonia is a common cause of illness and death in the elderly and persons with certain underlying conditions such as heart failure, diabetes, cystic fibrosis, asthma, sickle cell anemia, or chronic obstructive pulmonary disease (NHLBI, 2011). In 1998, an estimated 3,400 adults aged > 65 years died as a result of invasive pneumococcal disease (IPD) (CDC, 2003).\n\nAmong the 91.5 million US adults aged > 50 years, 29,500 cases of IPD, 502,600 cases of nonbacteremic pneumococcal pneumonia and 25,400 pneumococcal-related deaths are estimated to occur yearly; annual direct and indirect costs are estimated to total $3.7 billion and $1.8 billion, respectively. Pneumococcal disease remains a substantial burden among older US adults, despite increased coverage with 23-valent pneumococcal polysaccharide vaccine, (PPV23) and indirect benefits afforded by PCV7 vaccination of young children (Weycker, et al., 2011).\n\nVaccination has been found to be effective against bacteremic cases (OR: 0.34; 95% CI: 0.27-0.66) as well as nonbacteremic cases (OR: 0.58; 95% CI: 0.39-0.86). Vaccine effectiveness was highest against bacteremic infections caused by vaccine types (OR: 0.24; 95% CI: 0.09-0.66) (Vila-Corcoles, et al., 2009).",
                "media_type": "text/plain"
              }
            },
            {
              "code": "CRS",
              "value": "In 2014, the Advisory Committee on Immunization Practices (ACIP) began recommending a dose of 13-valent pneumococcal conjugate vaccine (PCV13) be followed by a dose of 23-valent pneumococcal polysaccharide vaccine (PPSV23) 6-12 months later in adults aged 65 and older who have not previously received a pneumococcal vaccination, and in persons over the age of two years who are considered to be at higher risk for pneumococcal disease due to an underlying condition. The two vaccines should not be coadministered and intervals for administration of the two vaccines vary slightly depending on the age, risk group, and history of vaccination (Kobayashi, 2015).\n\nIn 2015, ACIP updated its recommendation and changed the interval between PCV13 and PPSV23, from 6-12 months to at least one year for immunocompetent adults aged >=65 years who have not previously received pneumococcal vaccine. For immunocompromised vaccine-naïve adults, the minimum acceptable interval between PCV13 and PPSV23 is 8 weeks. Both immunocompetent and immunocompromised adults aged >=65 years who have previously received a dose of PPSV23 when over the age of 65 should receive a dose of PCV13 at least one year after PPSV23 (>=1 year). Immunocompetent and immunocompromised adults aged >=65 who have previously received a dose of PPSV23 when under the age of 65, should also receive a dose of PCV13 at least one year after PPSV23 (>=1 year) and then another dose of PPSV23 at least one year after PCV13. It is recommended that for those that have this alternative three-dose schedule (2 PPSV23 and 1 PCV13), the three doses should be spread over a time period of five or more years (Kobayashi, 2015).",
              "name": "Clinical Recommendation Statement",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "CRS",
                "title": "Clinical Recommendation Statement"
              },
              "value_obj": {
                "type": "ED",
                "value": "In 2014, the Advisory Committee on Immunization Practices (ACIP) began recommending a dose of 13-valent pneumococcal conjugate vaccine (PCV13) be followed by a dose of 23-valent pneumococcal polysaccharide vaccine (PPSV23) 6-12 months later in adults aged 65 and older who have not previously received a pneumococcal vaccination, and in persons over the age of two years who are considered to be at higher risk for pneumococcal disease due to an underlying condition. The two vaccines should not be coadministered and intervals for administration of the two vaccines vary slightly depending on the age, risk group, and history of vaccination (Kobayashi, 2015).\n\nIn 2015, ACIP updated its recommendation and changed the interval between PCV13 and PPSV23, from 6-12 months to at least one year for immunocompetent adults aged >=65 years who have not previously received pneumococcal vaccine. For immunocompromised vaccine-naïve adults, the minimum acceptable interval between PCV13 and PPSV23 is 8 weeks. Both immunocompetent and immunocompromised adults aged >=65 years who have previously received a dose of PPSV23 when over the age of 65 should receive a dose of PCV13 at least one year after PPSV23 (>=1 year). Immunocompetent and immunocompromised adults aged >=65 who have previously received a dose of PPSV23 when under the age of 65, should also receive a dose of PCV13 at least one year after PPSV23 (>=1 year) and then another dose of PPSV23 at least one year after PCV13. It is recommended that for those that have this alternative three-dose schedule (2 PPSV23 and 1 PCV13), the three doses should be spread over a time period of five or more years (Kobayashi, 2015).",
                "media_type": "text/plain"
              }
            },
            {
              "code": "IDUR",
              "value": "Higher score indicates better quality",
              "name": "Improvement Notation",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "IDUR",
                "title": "Improvement Notation"
              },
              "value_obj": {
                "type": "ED",
                "value": "Higher score indicates better quality",
                "media_type": "text/plain"
              }
            },
            {
              "code": "REF",
              "value": "Kobayashi M, Bennett NM, Gierke R, et al. \"Intervals between PCV13 and PPSV23 vaccines: recommendations of the Advisory Committee on Immunization Practices (ACIP).\" MMWR. (2015);64(34):944-7.",
              "name": "Reference",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "REF",
                "title": "Reference"
              },
              "value_obj": {
                "type": "ED",
                "value": "Kobayashi M, Bennett NM, Gierke R, et al. \"Intervals between PCV13 and PPSV23 vaccines: recommendations of the Advisory Committee on Immunization Practices (ACIP).\" MMWR. (2015);64(34):944-7.",
                "media_type": "text/plain"
              }
            },
            {
              "code": "REF",
              "value": "National Heart, Lung and Blood Institute. 2011. \"Pneumonia.\" http://www.nhlbi.nih.gov/health/dci/Diseases/pnu/pnu_whatis.html",
              "name": "Reference",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "REF",
                "title": "Reference"
              },
              "value_obj": {
                "type": "ED",
                "value": "National Heart, Lung and Blood Institute. 2011. \"Pneumonia.\" http://www.nhlbi.nih.gov/health/dci/Diseases/pnu/pnu_whatis.html",
                "media_type": "text/plain"
              }
            },
            {
              "code": "REF",
              "value": "Weycker, D., D. Strutton, J. Edelsberg, R. Sato, L.A. Jackson. 2011. \"Clinical and Economic Burden of Pneumococcal Disease in Older US Adults.\" Vaccine 28(31): 4955-60.",
              "name": "Reference",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "REF",
                "title": "Reference"
              },
              "value_obj": {
                "type": "ED",
                "value": "Weycker, D., D. Strutton, J. Edelsberg, R. Sato, L.A. Jackson. 2011. \"Clinical and Economic Burden of Pneumococcal Disease in Older US Adults.\" Vaccine 28(31): 4955-60.",
                "media_type": "text/plain"
              }
            },
            {
              "code": "REF",
              "value": "Vila-Corcoles, A., E. Salsench, T. Rodriguez-Blanco, O. Ochoa-Gondar, C. de Diego, A. Valdivieso, I. Hospital, F. Gomez-Bertemeu, X. Raga. 2009. \"Clinical effectiveness of 23-valent pneumococcal polysaccharide vaccine against pneumonia in middle-aged and older adults: A matched case-control study.\" Vaccine 27(10):1504-10.",
              "name": "Reference",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "REF",
                "title": "Reference"
              },
              "value_obj": {
                "type": "ED",
                "value": "Vila-Corcoles, A., E. Salsench, T. Rodriguez-Blanco, O. Ochoa-Gondar, C. de Diego, A. Valdivieso, I. Hospital, F. Gomez-Bertemeu, X. Raga. 2009. \"Clinical effectiveness of 23-valent pneumococcal polysaccharide vaccine against pneumonia in middle-aged and older adults: A matched case-control study.\" Vaccine 27(10):1504-10.",
                "media_type": "text/plain"
              }
            },
            {
              "code": "DEF",
              "value": "None",
              "name": "Definition",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "DEF",
                "title": "Definition"
              },
              "value_obj": {
                "type": "ED",
                "value": "None",
                "media_type": "text/plain"
              }
            },
            {
              "code": "GUIDE",
              "value": "Patient self-report for procedures as well as immunizations should be recorded in 'Procedure, Performed' template or 'Immunization, Performed' template in QRDA-1.",
              "name": "Guidance",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "GUIDE",
                "title": "Guidance"
              },
              "value_obj": {
                "type": "ED",
                "value": "Patient self-report for procedures as well as immunizations should be recorded in 'Procedure, Performed' template or 'Immunization, Performed' template in QRDA-1.",
                "media_type": "text/plain"
              }
            },
            {
              "code": "TRANF",
              "value": "TBD",
              "name": "Transmission Format",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "TRANF",
                "title": "Transmission Format"
              },
              "value_obj": {
                "type": "ED",
                "value": "TBD",
                "media_type": "text/plain"
              }
            },
            {
              "code": "IPOP",
              "value": "Patients 65 years of age and older with a visit during the measurement period",
              "name": "Initial Population",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "IPOP",
                "title": "Initial Population"
              },
              "value_obj": {
                "type": "ED",
                "value": "Patients 65 years of age and older with a visit during the measurement period",
                "media_type": "text/plain"
              }
            },
            {
              "code": "DENOM",
              "value": "Equals Initial Population",
              "name": "Denominator",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "DENOM",
                "title": "Denominator"
              },
              "value_obj": {
                "type": "ED",
                "value": "Equals Initial Population",
                "media_type": "text/plain"
              }
            },
            {
              "code": "DENEX",
              "value": "Exclude patients whose hospice care overlaps the measurement period",
              "name": "Denominator Exclusions",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "DENEX",
                "title": "Denominator Exclusions"
              },
              "value_obj": {
                "type": "ED",
                "value": "Exclude patients whose hospice care overlaps the measurement period",
                "media_type": "text/plain"
              }
            },
            {
              "code": "NUMER",
              "value": "Patients who have ever received a pneumococcal vaccination",
              "name": "Numerator",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "NUMER",
                "title": "Numerator"
              },
              "value_obj": {
                "type": "ED",
                "value": "Patients who have ever received a pneumococcal vaccination",
                "media_type": "text/plain"
              }
            },
            {
              "code": "NUMEX",
              "value": "Not Applicable",
              "name": "Numerator Exclusions",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "NUMEX",
                "title": "Numerator Exclusions"
              },
              "value_obj": {
                "type": "ED",
                "value": "Not Applicable",
                "media_type": "text/plain"
              }
            },
            {
              "code": "DENEXCEP",
              "value": "None",
              "name": "Denominator Exceptions",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "DENEXCEP",
                "title": "Denominator Exceptions"
              },
              "value_obj": {
                "type": "ED",
                "value": "None",
                "media_type": "text/plain"
              }
            },
            {
              "code": "SDE",
              "value": "For every patient evaluated by this measure also identify payer, race, ethnicity and sex",
              "name": "Supplemental Data Elements",
              "code_obj": {
                "type": "CD",
                "system": "2.16.840.1.113883.5.4",
                "code": "SDE",
                "title": "Supplemental Data Elements"
              },
              "value_obj": {
                "type": "ED",
                "value": "For every patient evaluated by this measure also identify payer, race, ethnicity and sex",
                "media_type": "text/plain"
              }
            }
          ],
          "populations": [
            {
              "IPP": "IPP",
              "DENOM": "DENOM",
              "NUMER": "NUMER",
              "DENEX": "DENEX",
              "id": "PopulationCriteria1",
              "title": "Population Criteria Section"
            }
          ],
          "measure_period": {
            "type": "IVL_TS",
            "low": {
              "type": "TS",
              "value": "201201010000",
              "inclusive?": true,
              "derived?": false
            },
            "high": {
              "type": "TS",
              "value": "201212312359",
              "inclusive?": true,
              "derived?": false
            },
            "width": {
              "type": "PQ",
              "unit": "a",
              "value": "1",
              "inclusive?": true,
              "derived?": false
            }
          },
          "continuous_variable": false,
          "episode_of_care": false,
          "hqmf_document": {
            "source_data_criteria": {
              "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b_source": {
                "title": "PneumococcalVaccineAdministered",
                "description": "Procedure, Performed: PneumococcalVaccineAdministered",
                "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1034",
                "type": "procedures",
                "definition": "procedure",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b_source",
                "variable": false
              },
              "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344_source": {
                "title": "Payer",
                "description": "Patient Characteristic Payer: Payer",
                "code_list_id": "2.16.840.1.114222.4.11.3591",
                "property": "payer",
                "type": "characteristic",
                "definition": "patient_characteristic_payer",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344_source",
                "variable": false,
                "inline_code_list": {
                  "Source of Payment Typology": [
                    "1",
                    "11",
                    "111",
                    "112",
                    "113",
                    "119",
                    "12",
                    "121",
                    "122",
                    "123",
                    "129",
                    "13",
                    "14",
                    "19",
                    "191",
                    "2",
                    "21",
                    "211",
                    "212",
                    "213",
                    "219",
                    "22",
                    "23",
                    "24",
                    "25",
                    "26",
                    "29",
                    "291",
                    "299",
                    "3",
                    "31",
                    "311",
                    "3111",
                    "3112",
                    "3113",
                    "3114",
                    "3115",
                    "3116",
                    "3119",
                    "312",
                    "3121",
                    "3122",
                    "3123",
                    "313",
                    "32",
                    "321",
                    "3211",
                    "3212",
                    "32121",
                    "32122",
                    "32123",
                    "32124",
                    "32125",
                    "32126",
                    "32127",
                    "32128",
                    "322",
                    "3221",
                    "3222",
                    "3223",
                    "3229",
                    "33",
                    "331",
                    "332",
                    "333",
                    "334",
                    "34",
                    "341",
                    "342",
                    "343",
                    "349",
                    "35",
                    "36",
                    "361",
                    "362",
                    "369",
                    "37",
                    "371",
                    "3711",
                    "3712",
                    "3713",
                    "372",
                    "379",
                    "38",
                    "381",
                    "3811",
                    "3812",
                    "3813",
                    "3819",
                    "382",
                    "389",
                    "39",
                    "391",
                    "4",
                    "41",
                    "42",
                    "43",
                    "44",
                    "5",
                    "51",
                    "511",
                    "512",
                    "513",
                    "514",
                    "515",
                    "516",
                    "517",
                    "519",
                    "52",
                    "521",
                    "522",
                    "523",
                    "524",
                    "529",
                    "53",
                    "54",
                    "55",
                    "56",
                    "561",
                    "562",
                    "59",
                    "6",
                    "61",
                    "611",
                    "612",
                    "613",
                    "614",
                    "619",
                    "62",
                    "621",
                    "622",
                    "623",
                    "629",
                    "7",
                    "71",
                    "72",
                    "73",
                    "79",
                    "8",
                    "81",
                    "82",
                    "821",
                    "822",
                    "823",
                    "83",
                    "84",
                    "85",
                    "89",
                    "9",
                    "91",
                    "92",
                    "93",
                    "94",
                    "95",
                    "951",
                    "953",
                    "954",
                    "959",
                    "96",
                    "97",
                    "98",
                    "99",
                    "9999"
                  ]
                }
              },
              "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d_source": {
                "title": "ONCAdministrativeSex",
                "description": "Patient Characteristic Sex: ONCAdministrativeSex",
                "code_list_id": "2.16.840.1.113762.1.4.1",
                "property": "gender",
                "type": "characteristic",
                "definition": "patient_characteristic_gender",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d_source",
                "variable": false,
                "value": {
                  "type": "CD",
                  "system": "Administrative Sex",
                  "code": "F"
                }
              },
              "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b_source": {
                "title": "CareServicesinLong-TermResidentialFacility",
                "description": "Encounter, Performed: CareServicesinLong-TermResidentialFacility",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1014",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b_source",
                "variable": false
              },
              "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3_source": {
                "title": "EncounterInpatient",
                "description": "Encounter, Performed: EncounterInpatient",
                "code_list_id": "2.16.840.1.113883.3.666.5.307",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3_source",
                "variable": false
              },
              "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e_source": {
                "title": "PreventiveCareServices-EstablishedOfficeVisit18andUp",
                "description": "Encounter, Performed: PreventiveCareServices-EstablishedOfficeVisit18andUp",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1025",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e_source",
                "variable": false
              },
              "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30_source": {
                "title": "AnnualWellnessVisit",
                "description": "Encounter, Performed: AnnualWellnessVisit",
                "code_list_id": "2.16.840.1.113883.3.526.3.1240",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30_source",
                "variable": false
              },
              "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098_source": {
                "title": "Hospicecareambulatory",
                "description": "Intervention, Order: Hospicecareambulatory",
                "code_list_id": "2.16.840.1.113762.1.4.1108.15",
                "type": "interventions",
                "definition": "intervention",
                "status": "ordered",
                "hard_status": true,
                "negation": false,
                "source_data_criteria": "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
                "variable": false
              },
              "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098_source": {
                "title": "Hospicecareambulatory",
                "description": "Intervention, Performed: Hospicecareambulatory",
                "code_list_id": "2.16.840.1.113762.1.4.1108.15",
                "type": "interventions",
                "definition": "intervention",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
                "variable": false
              },
              "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271_source": {
                "title": "Ethnicity",
                "description": "Patient Characteristic Ethnicity: Ethnicity",
                "code_list_id": "2.16.840.1.114222.4.11.837",
                "property": "ethnicity",
                "type": "characteristic",
                "definition": "patient_characteristic_ethnicity",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271_source",
                "variable": false,
                "inline_code_list": {
                  "CDC Race": [
                    "2135-2",
                    "2186-5"
                  ]
                }
              },
              "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968_source": {
                "title": "DischargeServices-NursingFacility",
                "description": "Encounter, Performed: DischargeServices-NursingFacility",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.11.1065",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968_source",
                "variable": false
              },
              "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32_source": {
                "title": "HomeHealthcareServices",
                "description": "Encounter, Performed: HomeHealthcareServices",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1016",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32_source",
                "variable": false
              },
              "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113_source": {
                "title": "PneumococcalVaccine",
                "description": "Immunization, Administered: PneumococcalVaccine",
                "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1027",
                "type": "immunizations",
                "definition": "immunization",
                "status": "administered",
                "hard_status": true,
                "negation": false,
                "source_data_criteria": "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113_source",
                "variable": false
              },
              "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7_source": {
                "title": "Race",
                "description": "Patient Characteristic Race: Race",
                "code_list_id": "2.16.840.1.114222.4.11.836",
                "property": "race",
                "type": "characteristic",
                "definition": "patient_characteristic_race",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7_source",
                "variable": false,
                "inline_code_list": {
                  "CDC Race": [
                    "1002-5",
                    "2028-9",
                    "2054-5",
                    "2076-8",
                    "2106-3",
                    "2131-1"
                  ]
                }
              },
              "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e_source": {
                "title": "NursingFacilityVisit",
                "description": "Encounter, Performed: NursingFacilityVisit",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1012",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e_source",
                "variable": false
              },
              "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d_source": {
                "title": "OfficeVisit",
                "description": "Encounter, Performed: OfficeVisit",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1001",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d_source",
                "variable": false
              },
              "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f_source": {
                "title": "PreventiveCareServices-InitialOfficeVisit18andUp",
                "description": "Encounter, Performed: PreventiveCareServices-InitialOfficeVisit18andUp",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1023",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f_source",
                "variable": false
              }
            },
            "data_criteria": {
              "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b": {
                "title": "PneumococcalVaccineAdministered",
                "description": "Procedure, Performed: PneumococcalVaccineAdministered",
                "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1034",
                "type": "procedures",
                "definition": "procedure",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "PneumococcalVaccineAdministered_ProcedurePerformed_40280381_3d61_56a7_013e_66a79d664a2b_source",
                "variable": false
              },
              "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344": {
                "title": "Payer",
                "description": "Patient Characteristic Payer: Payer",
                "code_list_id": "2.16.840.1.114222.4.11.3591",
                "property": "payer",
                "type": "characteristic",
                "definition": "patient_characteristic_payer",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Payer_PatientCharacteristicPayer_addd8d7a_a98f_4783_a7c2_b715c1151344_source",
                "variable": false,
                "inline_code_list": {
                  "Source of Payment Typology": [
                    "1",
                    "11",
                    "111",
                    "112",
                    "113",
                    "119",
                    "12",
                    "121",
                    "122",
                    "123",
                    "129",
                    "13",
                    "14",
                    "19",
                    "191",
                    "2",
                    "21",
                    "211",
                    "212",
                    "213",
                    "219",
                    "22",
                    "23",
                    "24",
                    "25",
                    "26",
                    "29",
                    "291",
                    "299",
                    "3",
                    "31",
                    "311",
                    "3111",
                    "3112",
                    "3113",
                    "3114",
                    "3115",
                    "3116",
                    "3119",
                    "312",
                    "3121",
                    "3122",
                    "3123",
                    "313",
                    "32",
                    "321",
                    "3211",
                    "3212",
                    "32121",
                    "32122",
                    "32123",
                    "32124",
                    "32125",
                    "32126",
                    "32127",
                    "32128",
                    "322",
                    "3221",
                    "3222",
                    "3223",
                    "3229",
                    "33",
                    "331",
                    "332",
                    "333",
                    "334",
                    "34",
                    "341",
                    "342",
                    "343",
                    "349",
                    "35",
                    "36",
                    "361",
                    "362",
                    "369",
                    "37",
                    "371",
                    "3711",
                    "3712",
                    "3713",
                    "372",
                    "379",
                    "38",
                    "381",
                    "3811",
                    "3812",
                    "3813",
                    "3819",
                    "382",
                    "389",
                    "39",
                    "391",
                    "4",
                    "41",
                    "42",
                    "43",
                    "44",
                    "5",
                    "51",
                    "511",
                    "512",
                    "513",
                    "514",
                    "515",
                    "516",
                    "517",
                    "519",
                    "52",
                    "521",
                    "522",
                    "523",
                    "524",
                    "529",
                    "53",
                    "54",
                    "55",
                    "56",
                    "561",
                    "562",
                    "59",
                    "6",
                    "61",
                    "611",
                    "612",
                    "613",
                    "614",
                    "619",
                    "62",
                    "621",
                    "622",
                    "623",
                    "629",
                    "7",
                    "71",
                    "72",
                    "73",
                    "79",
                    "8",
                    "81",
                    "82",
                    "821",
                    "822",
                    "823",
                    "83",
                    "84",
                    "85",
                    "89",
                    "9",
                    "91",
                    "92",
                    "93",
                    "94",
                    "95",
                    "951",
                    "953",
                    "954",
                    "959",
                    "96",
                    "97",
                    "98",
                    "99",
                    "9999"
                  ]
                }
              },
              "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d": {
                "title": "ONCAdministrativeSex",
                "description": "Patient Characteristic Sex: ONCAdministrativeSex",
                "code_list_id": "2.16.840.1.113762.1.4.1",
                "property": "gender",
                "type": "characteristic",
                "definition": "patient_characteristic_gender",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "ONCAdministrativeSex_PatientCharacteristicSex_5e565245_57d9_491c_ac87_4215b45a213d_source",
                "variable": false,
                "value": {
                  "type": "CD",
                  "system": "Administrative Sex",
                  "code": "F"
                }
              },
              "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b": {
                "title": "CareServicesinLong-TermResidentialFacility",
                "description": "Encounter, Performed: CareServicesinLong-TermResidentialFacility",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1014",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "CareServicesinLong_TermResidentialFacility_EncounterPerformed_f01834e0_bd4b_4d66_bda3_1e9471b5b70b_source",
                "variable": false
              },
              "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3": {
                "title": "EncounterInpatient",
                "description": "Encounter, Performed: EncounterInpatient",
                "code_list_id": "2.16.840.1.113883.3.666.5.307",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "EncounterInpatient_EncounterPerformed_59c3933e_c568_4119_b89d_c29b7c752ef3_source",
                "variable": false
              },
              "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e": {
                "title": "PreventiveCareServices-EstablishedOfficeVisit18andUp",
                "description": "Encounter, Performed: PreventiveCareServices-EstablishedOfficeVisit18andUp",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1025",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "PreventiveCareServices_EstablishedOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2e_source",
                "variable": false
              },
              "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30": {
                "title": "AnnualWellnessVisit",
                "description": "Encounter, Performed: AnnualWellnessVisit",
                "code_list_id": "2.16.840.1.113883.3.526.3.1240",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "AnnualWellnessVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a30_source",
                "variable": false
              },
              "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098": {
                "title": "Hospicecareambulatory",
                "description": "Intervention, Order: Hospicecareambulatory",
                "code_list_id": "2.16.840.1.113762.1.4.1108.15",
                "type": "interventions",
                "definition": "intervention",
                "status": "ordered",
                "hard_status": true,
                "negation": false,
                "source_data_criteria": "Hospicecareambulatory_InterventionOrder_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
                "variable": false
              },
              "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098": {
                "title": "Hospicecareambulatory",
                "description": "Intervention, Performed: Hospicecareambulatory",
                "code_list_id": "2.16.840.1.113762.1.4.1108.15",
                "type": "interventions",
                "definition": "intervention",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Hospicecareambulatory_InterventionPerformed_95cca057_9695_4ee4_a5bd_eff4b54c6098_source",
                "variable": false
              },
              "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271": {
                "title": "Ethnicity",
                "description": "Patient Characteristic Ethnicity: Ethnicity",
                "code_list_id": "2.16.840.1.114222.4.11.837",
                "property": "ethnicity",
                "type": "characteristic",
                "definition": "patient_characteristic_ethnicity",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Ethnicity_PatientCharacteristicEthnicity_6b9dc81d_c814_4c21_80ff_a1ec70f30271_source",
                "variable": false,
                "inline_code_list": {
                  "CDC Race": [
                    "2135-2",
                    "2186-5"
                  ]
                }
              },
              "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968": {
                "title": "DischargeServices-NursingFacility",
                "description": "Encounter, Performed: DischargeServices-NursingFacility",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.11.1065",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "DischargeServices_NursingFacility_EncounterPerformed_e05cf706_6c59_4c3e_b431_852a6e7ba968_source",
                "variable": false
              },
              "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32": {
                "title": "HomeHealthcareServices",
                "description": "Encounter, Performed: HomeHealthcareServices",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1016",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "HomeHealthcareServices_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a32_source",
                "variable": false
              },
              "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113": {
                "title": "PneumococcalVaccine",
                "description": "Immunization, Administered: PneumococcalVaccine",
                "code_list_id": "2.16.840.1.113883.3.464.1003.110.12.1027",
                "type": "immunizations",
                "definition": "immunization",
                "status": "administered",
                "hard_status": true,
                "negation": false,
                "source_data_criteria": "PneumococcalVaccine_ImmunizationAdministered_f2740af4_6396_4925_a953_e80fdb06a113_source",
                "variable": false
              },
              "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7": {
                "title": "Race",
                "description": "Patient Characteristic Race: Race",
                "code_list_id": "2.16.840.1.114222.4.11.836",
                "property": "race",
                "type": "characteristic",
                "definition": "patient_characteristic_race",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "Race_PatientCharacteristicRace_42416b0a_d717_4bd9_bebe_8af7d5170fc7_source",
                "variable": false,
                "inline_code_list": {
                  "CDC Race": [
                    "1002-5",
                    "2028-9",
                    "2054-5",
                    "2076-8",
                    "2106-3",
                    "2131-1"
                  ]
                }
              },
              "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e": {
                "title": "NursingFacilityVisit",
                "description": "Encounter, Performed: NursingFacilityVisit",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1012",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "NursingFacilityVisit_EncounterPerformed_2478b811_d7b4_4fb7_a149_bee93d16205e_source",
                "variable": false
              },
              "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d": {
                "title": "OfficeVisit",
                "description": "Encounter, Performed: OfficeVisit",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1001",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "OfficeVisit_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2d_source",
                "variable": false
              },
              "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f": {
                "title": "PreventiveCareServices-InitialOfficeVisit18andUp",
                "description": "Encounter, Performed: PreventiveCareServices-InitialOfficeVisit18andUp",
                "code_list_id": "2.16.840.1.113883.3.464.1003.101.12.1023",
                "type": "encounters",
                "definition": "encounter",
                "status": "performed",
                "hard_status": false,
                "negation": false,
                "source_data_criteria": "PreventiveCareServices_InitialOfficeVisit18andUp_EncounterPerformed_40280381_3d61_56a7_013e_66a79d664a2f_source",
                "variable": false
              }
            }
          },
          "observations": [
        
          ],
          "cql": [
            "library PneumococcalVaccinationStatusforOlderAdults version '7.2.000'\r\n\r\nusing QDM version '5.3'\r\n\r\ninclude MATGlobalCommonFunctions version '2.0.000' called Global\r\ninclude Hospice version '1.0.000' called Hospice\r\n\r\nvalueset \"ONC Administrative Sex\": 'urn:oid:2.16.840.1.113762.1.4.1'\r\nvalueset \"Race\": 'urn:oid:2.16.840.1.114222.4.11.836'\r\nvalueset \"Ethnicity\": 'urn:oid:2.16.840.1.114222.4.11.837'\r\nvalueset \"Payer\": 'urn:oid:2.16.840.1.114222.4.11.3591'\r\nvalueset \"Annual Wellness Visit\": 'urn:oid:2.16.840.1.113883.3.526.3.1240'\r\nvalueset \"Home Healthcare Services\": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1016'\r\nvalueset \"Office Visit\": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1001'\r\nvalueset \"Pneumococcal Vaccine\": 'urn:oid:2.16.840.1.113883.3.464.1003.110.12.1027'\r\nvalueset \"Pneumococcal Vaccine Administered\": 'urn:oid:2.16.840.1.113883.3.464.1003.110.12.1034'\r\nvalueset \"Preventive Care Services - Established Office Visit, 18 and Up\": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1025'\r\nvalueset \"Preventive Care Services-Initial Office Visit, 18 and Up\": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1023'\r\nvalueset \"Care Services in Long-Term Residential Facility\": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1014'\r\nvalueset \"Nursing Facility Visit\": 'urn:oid:2.16.840.1.113883.3.464.1003.101.12.1012'\r\nvalueset \"Discharge Services - Nursing Facility\": 'urn:oid:2.16.840.1.113883.3.464.1003.101.11.1065'\r\n\r\nparameter \"Measurement Period\" Interval<DateTime>\r\n\r\ncontext Patient\r\n\r\ndefine \"SDE Ethnicity\":\r\n\t[\"Patient Characteristic Ethnicity\": \"Ethnicity\"]\r\n\r\ndefine \"SDE Payer\":\r\n\t[\"Patient Characteristic Payer\": \"Payer\"]\r\n\r\ndefine \"SDE Race\":\r\n\t[\"Patient Characteristic Race\": \"Race\"]\r\n\r\ndefine \"SDE Sex\":\r\n\t[\"Patient Characteristic Sex\": \"ONC Administrative Sex\"]\r\n\r\ndefine \"Denominator\":\r\n\t\"Initial Population\"\r\n\r\ndefine \"Qualifying Encounters\":\r\n\t( [\"Encounter, Performed\": \"Office Visit\"]\r\n\t\tunion [\"Encounter, Performed\": \"Annual Wellness Visit\"]\r\n\t\tunion [\"Encounter, Performed\": \"Preventive Care Services - Established Office Visit, 18 and Up\"]\r\n\t\tunion [\"Encounter, Performed\": \"Preventive Care Services-Initial Office Visit, 18 and Up\"]\r\n\t\tunion [\"Encounter, Performed\": \"Home Healthcare Services\"]\r\n\t\tunion [\"Encounter, Performed\": \"Care Services in Long-Term Residential Facility\"]\r\n\t\tunion [\"Encounter, Performed\": \"Nursing Facility Visit\"]\r\n\t\tunion [\"Encounter, Performed\": \"Discharge Services - Nursing Facility\"] ) ValidEncounter\r\n\t\twhere ValidEncounter.relevantPeriod during \"Measurement Period\"\r\n\r\ndefine \"Numerator\":\r\n\texists ( [\"Immunization, Administered\": \"Pneumococcal Vaccine\"] PneumococcalVaccine\r\n\t\t\twhere PneumococcalVaccine.authorDatetime on or before end of \"Measurement Period\"\r\n\t)\r\n\t\tor exists ( [\"Procedure, Performed\": \"Pneumococcal Vaccine Administered\"] PneumococcalVaccineGiven\r\n\t\t\t\twhere PneumococcalVaccineGiven.relevantPeriod starts on or before end of \"Measurement Period\"\r\n\t\t)\r\n\r\ndefine \"Denominator Exclusions\":\r\n\tHospice.\"Has Hospice\"\r\n\r\ndefine \"Initial Population\":\r\n\texists ( [\"Patient Characteristic Birthdate\"] BirthDate\r\n\t\t\twhere Global.\"CalendarAgeInYearsAt\"(BirthDate.birthDatetime, start of \"Measurement Period\")>= 65\r\n\t)\r\n\t\tand exists \"Qualifying Encounters\"\r\n",
            "library MATGlobalCommonFunctions version '2.0.000'\r\n\r\nusing QDM version '5.3'\r\n\r\ncodesystem \"LOINC:2.46\": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'\r\ncodesystem \"SNOMEDCT:2016-03\": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'\r\n\r\nvalueset \"Emergency Department Visit\": 'urn:oid:2.16.840.1.113883.3.117.1.7.1.292'\r\nvalueset \"Encounter Inpatient\": 'urn:oid:2.16.840.1.113883.3.666.5.307'\r\nvalueset \"Intensive Care Unit\": 'urn:oid:2.16.840.1.113762.1.4.1110.23'\r\n\r\ncode \"Birthdate\": '21112-8' from \"LOINC:2.46\" display 'Birth date'\r\ncode \"Dead\": '419099009' from \"SNOMEDCT:2016-03\" display 'Dead'\r\n\r\nparameter \"Measurement Period\" Interval<DateTime>\r\n\r\ncontext Patient\r\n\r\ndefine \"Encounter\":\r\n\t[\"Encounter, Performed\": \"Emergency Department Visit\"]\r\n\r\ndefine \"Inpatient Encounter\":\r\n\t[\"Encounter, Performed\": \"Encounter Inpatient\"] EncounterInpatient\r\n\t\twhere \"LengthInDays\"(EncounterInpatient.relevantPeriod)<= 120\r\n\t\t\tand EncounterInpatient.relevantPeriod ends during \"Measurement Period\"\n\n/*ToDate takes a given DateTime value and returns a DateTime with the time components \"zeroed\", and the timezone of the input value, for example, given the DateTime @2012-01-01T06:30:00.0Z, this function will return @2012-01-01T00:00:00.0Z.*/\r\n\r\ndefine function \"ToDate\"(Value DateTime):\r\n\tDateTime(year from Value, month from Value, day from Value, 0, 0, 0, 0, timezone from Value)\n\n/*CalendarAgeInDaysAt calculates the calendar age (meaning the age without considering time components) in days.*/\r\n\r\ndefine function \"CalendarAgeInDaysAt\"(BirthDateTime DateTime, AsOf DateTime):\r\n\tdays between ToDate(BirthDateTime)and ToDate(AsOf)\n\n/*CalendarAgeInDays calculates the calendar age (meaning the age without considering time components) in days as of today*/\r\n\r\ndefine function \"CalendarAgeInDays\"(BirthDateTime DateTime):\r\n\tCalendarAgeInDaysAt(BirthDateTime, Today())\n\n/*CalendarAgeInMonthsAt calculates the calendar age (meaning the age without considering time components) in months.*/\r\n\r\ndefine function \"CalendarAgeInMonthsAt\"(BirthDateTime DateTime, AsOf DateTime):\r\n\tmonths between ToDate(BirthDateTime)and ToDate(AsOf)\n\n/*CalendarAgeInMonths calculates the calendar age (meaning the age without considering time components) in months as of today.*/\r\n\r\ndefine function \"CalendarAgeInMonths\"(BirthDateTime DateTime):\r\n\tCalendarAgeInMonthsAt(BirthDateTime, Today())\n\n/*CalendarAgeInYearsAt calculates the calendar age (meaning the age without considering time components) in years.*/\r\n\r\ndefine function \"CalendarAgeInYearsAt\"(BirthDateTime DateTime, AsOf DateTime):\r\n\tyears between ToDate(BirthDateTime)and ToDate(AsOf)\n\n/*CalendarAgeInYears calculates the calendar age (meaning the age without considering time components) in years as of today.*/\r\n\r\ndefine function \"CalendarAgeInYears\"(BirthDateTime DateTime):\r\n\tCalendarAgeInYearsAt(BirthDateTime, Today())\n\n/*Hospitalization returns the total interval for admission to discharge for the given encounter, or for the admission of any immediately prior emergency department visit to the discharge of the given encounter.*/\r\n\r\ndefine function \"Hospitalization\"(Encounter \"Encounter, Performed\"):\r\n\t( singleton from ( [\"Encounter, Performed\": \"Emergency Department Visit\"] EDVisit\r\n\t\t\twhere EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod\r\n\t) ) X\r\n\t\treturn if X is null then Encounter.relevantPeriod else Interval[start of X.relevantPeriod, end of Encounter.relevantPeriod]\n\n/*calculates the difference in calendar days between the start and end of the given interval.*/\r\n\r\ndefine function \"LengthInDays\"(Value Interval<DateTime>):\r\n\tdifference in days between start of Value and end of Value\n\n/* returns list of all locations within an encounter, including locations for immediately prior ED visit.  If data contains many encounters within 1 hour before the start of encounter error will occur indicating the hospitalization cannot be determined*/\r\n\r\ndefine function \"Hospitalization Locations\"(Encounter \"Encounter, Performed\"):\r\n\t( singleton from ( [\"Encounter, Performed\": \"Emergency Department Visit\"] EDVisit\r\n\t\t\twhere EDVisit.relevantPeriod ends 1 hour or less on or before start of Encounter.relevantPeriod\r\n\t) ) EDEncounter\r\n\t\treturn if EDEncounter is null then Encounter.facilityLocations else flatten { EDEncounter.facilityLocations, Encounter.facilityLocations }\n\n/*Returns the length of stay in days (i.e. the number of days between admission and discharge) for the given encounter, or from the admission of any immediately prior emergency department visit to the discharge of the encounter*/\r\n\r\ndefine function \"Hospitalization Length of Stay\"(Encounter \"Encounter, Performed\"):\r\n\tLengthInDays(\"Hospitalization\"(Encounter))\n\n/*Returns admission time for an encounter or for immediately prior emergency department visit.  If the data contain many encounters within 1 hour before the start of the encounter an error indicating hospitalization cannot be determined\n*/\r\n\r\ndefine function \"Hospital Admission Time\"(Encounter \"Encounter, Performed\"):\r\n\tstart of \"Hospitalization\"(Encounter)\n\n/*Hospital Discharge Time returns the discharge time for an encounter*/\r\n\r\ndefine function \"Hospital Discharge Time\"(Encounter \"Encounter, Performed\"):\r\n\tend of Encounter.relevantPeriod\n\n/*Returns earliest arrival time for an encounter including any prior ED visit. If the data contain multiple encounters within 1 hour before the start of the encounter, an error will occur indicating it cannot be unambiguously determined\n*/\r\n\r\ndefine function \"Hospital Arrival Time\"(Encounter \"Encounter, Performed\"):\r\n\tstart of First((\"Hospitalization Locations\"(Encounter))HospitalLocation\r\n\t\t\tsort by start of locationPeriod\r\n\t).locationPeriod\n\n/*Returns the latest departure time for encounter including any prior ED visit. If the data contain multiple encounters within 1 hour before the start of the encounter, an error will occur indicating it cannot be unambiguously determined*/\r\n\r\ndefine function \"Hospital Departure Time\"(Encounter \"Encounter, Performed\"):\r\n\tend of Last((\"Hospitalization Locations\"(Encounter))HospitalLocation\r\n\t\t\tsort by start of locationPeriod\r\n\t).locationPeriod\n\n/*Returns the arrival time in the ED for the encounter.  If the data contain multiple encounters within 1 hour before the start of the encounter or multiple ED locations an error will occur indicating it cannot be determined\n*/\r\n\r\ndefine function \"Emergency Department Arrival Time\"(Encounter \"Encounter, Performed\"):\r\n\tstart of ( singleton from ( ( \"Hospitalization Locations\"(Encounter)) HospitalLocation\r\n\t\t\t\twhere HospitalLocation.code in \"Emergency Department Visit\"\r\n\t\t)\r\n\t).locationPeriod\n\n/*First Inpatient Intensive Care Unit returns the first intensive care unit for\nthe given encounter, without considering any immediately prior emergency\ndepartment visit.*/\r\n\r\ndefine function \"First Inpatient Intensive Care Unit\"(Encounter \"Encounter, Performed\"):\r\n\tFirst((Encounter.facilityLocations)HospitalLocation\r\n\t\t\twhere HospitalLocation.code in \"Intensive Care Unit\"\r\n\t\t\t\tand HospitalLocation.locationPeriod during Encounter.relevantPeriod\r\n\t\t\tsort by start of locationPeriod\r\n\t)\r\n",
            "library Hospice version '1.0.000'\r\n\r\nusing QDM version '5.3'\r\n\r\ncodesystem \"LOINC:2.46\": 'urn:oid:2.16.840.1.113883.6.1' version 'urn:hl7:version:2.46'\r\ncodesystem \"SNOMEDCT:2016-03\": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2016-03'\r\ncodesystem \"SNOMEDCT:2017-03\": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-03'\r\ncodesystem \"SNOMEDCT:2017-09\": 'urn:oid:2.16.840.1.113883.6.96' version 'urn:hl7:version:2017-09'\r\n\r\nvalueset \"Encounter Inpatient\": 'urn:oid:2.16.840.1.113883.3.666.5.307'\r\nvalueset \"Hospice care ambulatory\": 'urn:oid:2.16.840.1.113762.1.4.1108.15'\r\n\r\ncode \"Birthdate\": '21112-8' from \"LOINC:2.46\" display 'Birth date'\r\ncode \"Dead\": '419099009' from \"SNOMEDCT:2016-03\" display 'Dead'\r\ncode \"Discharge to healthcare facility for hospice care (procedure)\": '428371000124100' from \"SNOMEDCT:2017-09\" display 'Discharge to healthcare facility for hospice care (procedure)'\r\ncode \"Discharge to home for hospice care (procedure)\": '428361000124107' from \"SNOMEDCT:2017-09\" display 'Discharge to home for hospice care (procedure)'\r\n\r\nparameter \"Measurement Period\" Interval<DateTime>\r\n\r\ncontext Patient\r\n\r\ndefine \"Has Hospice\":\r\n\texists ( [\"Encounter, Performed\": \"Encounter Inpatient\"] DischargeHospice\r\n\t\t\twhere ( DischargeHospice.dischargeDisposition as Code ~ \"Discharge to home for hospice care (procedure)\"\r\n\t\t\t\t\tor DischargeHospice.dischargeDisposition as Code ~ \"Discharge to healthcare facility for hospice care (procedure)\"\r\n\t\t\t)\r\n\t\t\t\tand DischargeHospice.relevantPeriod ends during \"Measurement Period\"\r\n\t)\r\n\t\tor exists ( [\"Intervention, Order\": \"Hospice care ambulatory\"] HospiceOrder\r\n\t\t\t\twhere HospiceOrder.authorDatetime during \"Measurement Period\"\r\n\t\t)\r\n\t\tor exists ( [\"Intervention, Performed\": \"Hospice care ambulatory\"] HospicePerformed\r\n\t\t\t\twhere HospicePerformed.relevantPeriod overlaps \"Measurement Period\"\r\n\t\t)\r\n"
          ],
          "elm": [
            {
              "library": {
                "identifier": {
                  "id": "PneumococcalVaccinationStatusforOlderAdults",
                  "version": "7.2.000"
                },
                "schemaIdentifier": {
                  "id": "urn:hl7-org:elm",
                  "version": "r1"
                },
                "usings": {
                  "def": [
                    {
                      "localIdentifier": "System",
                      "uri": "urn:hl7-org:elm-types:r1"
                    },
                    {
                      "localId": "1",
                      "locator": "3:1-3:23",
                      "localIdentifier": "QDM",
                      "uri": "urn:healthit-gov:qdm:v5_3",
                      "version": "5.3"
                    }
                  ]
                },
                "includes": {
                  "def": [
                    {
                      "localId": "2",
                      "locator": "5:1-5:64",
                      "localIdentifier": "Global",
                      "path": "MATGlobalCommonFunctions",
                      "version": "2.0.000"
                    },
                    {
                      "localId": "3",
                      "locator": "7:1-7:48",
                      "localIdentifier": "Hospice",
                      "path": "Hospice",
                      "version": "1.0.000"
                    }
                  ]
                },
                "parameters": {
                  "def": [
                    {
                      "localId": "20",
                      "locator": "26:1-26:49",
                      "name": "Measurement Period",
                      "accessLevel": "Public",
                      "parameterTypeSpecifier": {
                        "localId": "19",
                        "locator": "26:32-26:49",
                        "type": "IntervalTypeSpecifier",
                        "pointType": {
                          "localId": "18",
                          "locator": "26:41-26:48",
                          "name": "{urn:hl7-org:elm-types:r1}DateTime",
                          "type": "NamedTypeSpecifier"
                        }
                      }
                    }
                  ]
                },
                "valueSets": {
                  "def": [
                    {
                      "localId": "4",
                      "locator": "10:1-10:68",
                      "name": "ONC Administrative Sex",
                      "id": "2.16.840.1.113762.1.4.1",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "5",
                      "locator": "11:1-11:53",
                      "name": "Race",
                      "id": "2.16.840.1.114222.4.11.836",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "6",
                      "locator": "12:1-12:58",
                      "name": "Ethnicity",
                      "id": "2.16.840.1.114222.4.11.837",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "7",
                      "locator": "13:1-13:55",
                      "name": "Payer",
                      "id": "2.16.840.1.114222.4.11.3591",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "8",
                      "locator": "14:1-14:74",
                      "name": "Annual Wellness Visit",
                      "id": "2.16.840.1.113883.3.526.3.1240",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "9",
                      "locator": "15:1-15:87",
                      "name": "Home Healthcare Services",
                      "id": "2.16.840.1.113883.3.464.1003.101.12.1016",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "10",
                      "locator": "16:1-16:75",
                      "name": "Office Visit",
                      "id": "2.16.840.1.113883.3.464.1003.101.12.1001",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "11",
                      "locator": "17:1-17:83",
                      "name": "Pneumococcal Vaccine",
                      "id": "2.16.840.1.113883.3.464.1003.110.12.1027",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "12",
                      "locator": "18:1-18:96",
                      "name": "Pneumococcal Vaccine Administered",
                      "id": "2.16.840.1.113883.3.464.1003.110.12.1034",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "13",
                      "locator": "19:1-19:125",
                      "name": "Preventive Care Services - Established Office Visit, 18 and Up",
                      "id": "2.16.840.1.113883.3.464.1003.101.12.1025",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "14",
                      "locator": "20:1-20:119",
                      "name": "Preventive Care Services-Initial Office Visit, 18 and Up",
                      "id": "2.16.840.1.113883.3.464.1003.101.12.1023",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "15",
                      "locator": "21:1-21:110",
                      "name": "Care Services in Long-Term Residential Facility",
                      "id": "2.16.840.1.113883.3.464.1003.101.12.1014",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "16",
                      "locator": "22:1-22:85",
                      "name": "Nursing Facility Visit",
                      "id": "2.16.840.1.113883.3.464.1003.101.12.1012",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "17",
                      "locator": "23:1-23:100",
                      "name": "Discharge Services - Nursing Facility",
                      "id": "2.16.840.1.113883.3.464.1003.101.11.1065",
                      "accessLevel": "Public"
                    }
                  ]
                },
                "statements": {
                  "def": [
                    {
                      "locator": "28:1-28:15",
                      "name": "Patient",
                      "context": "Patient",
                      "expression": {
                        "type": "SingletonFrom",
                        "operand": {
                          "locator": "28:1-28:15",
                          "dataType": "{urn:healthit-gov:qdm:v5_3}Patient",
                          "templateId": "Patient",
                          "type": "Retrieve"
                        }
                      }
                    },
                    {
                      "localId": "22",
                      "locator": "30:1-31:50",
                      "name": "SDE Ethnicity",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "22",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"SDE Ethnicity\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "21",
                                "s": [
                                  {
                                    "value": [
                                      "[",
                                      "\"Patient Characteristic Ethnicity\"",
                                      ": "
                                    ]
                                  },
                                  {
                                    "s": [
                                      {
                                        "value": [
                                          "\"Ethnicity\""
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "]"
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "21",
                        "locator": "31:2-31:50",
                        "dataType": "{urn:healthit-gov:qdm:v5_3}PatientCharacteristicEthnicity",
                        "codeProperty": "code",
                        "type": "Retrieve",
                        "codes": {
                          "name": "Ethnicity",
                          "type": "ValueSetRef"
                        }
                      }
                    },
                    {
                      "localId": "24",
                      "locator": "33:1-34:42",
                      "name": "SDE Payer",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "24",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"SDE Payer\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "23",
                                "s": [
                                  {
                                    "value": [
                                      "[",
                                      "\"Patient Characteristic Payer\"",
                                      ": "
                                    ]
                                  },
                                  {
                                    "s": [
                                      {
                                        "value": [
                                          "\"Payer\""
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "]"
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "23",
                        "locator": "34:2-34:42",
                        "dataType": "{urn:healthit-gov:qdm:v5_3}PatientCharacteristicPayer",
                        "codeProperty": "code",
                        "type": "Retrieve",
                        "codes": {
                          "name": "Payer",
                          "type": "ValueSetRef"
                        }
                      }
                    },
                    {
                      "localId": "26",
                      "locator": "36:1-37:40",
                      "name": "SDE Race",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "26",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"SDE Race\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "25",
                                "s": [
                                  {
                                    "value": [
                                      "[",
                                      "\"Patient Characteristic Race\"",
                                      ": "
                                    ]
                                  },
                                  {
                                    "s": [
                                      {
                                        "value": [
                                          "\"Race\""
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "]"
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "25",
                        "locator": "37:2-37:40",
                        "dataType": "{urn:healthit-gov:qdm:v5_3}PatientCharacteristicRace",
                        "codeProperty": "code",
                        "type": "Retrieve",
                        "codes": {
                          "name": "Race",
                          "type": "ValueSetRef"
                        }
                      }
                    },
                    {
                      "localId": "28",
                      "locator": "39:1-40:57",
                      "name": "SDE Sex",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "28",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"SDE Sex\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "27",
                                "s": [
                                  {
                                    "value": [
                                      "[",
                                      "\"Patient Characteristic Sex\"",
                                      ": "
                                    ]
                                  },
                                  {
                                    "s": [
                                      {
                                        "value": [
                                          "\"ONC Administrative Sex\""
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "]"
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "27",
                        "locator": "40:2-40:57",
                        "dataType": "{urn:healthit-gov:qdm:v5_3}PatientCharacteristicSex",
                        "codeProperty": "code",
                        "type": "Retrieve",
                        "codes": {
                          "name": "ONC Administrative Sex",
                          "type": "ValueSetRef"
                        }
                      }
                    },
                    {
                      "localId": "62",
                      "locator": "45:1-54:65",
                      "name": "Qualifying Encounters",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "62",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Qualifying Encounters\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "61",
                                "s": [
                                  {
                                    "s": [
                                      {
                                        "r": "56",
                                        "s": [
                                          {
                                            "r": "55",
                                            "s": [
                                              {
                                                "value": [
                                                  "( "
                                                ]
                                              },
                                              {
                                                "r": "55",
                                                "s": [
                                                  {
                                                    "r": "53",
                                                    "s": [
                                                      {
                                                        "r": "51",
                                                        "s": [
                                                          {
                                                            "r": "49",
                                                            "s": [
                                                              {
                                                                "r": "47",
                                                                "s": [
                                                                  {
                                                                    "r": "45",
                                                                    "s": [
                                                                      {
                                                                        "r": "43",
                                                                        "s": [
                                                                          {
                                                                            "r": "41",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "[",
                                                                                  "\"Encounter, Performed\"",
                                                                                  ": "
                                                                                ]
                                                                              },
                                                                              {
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "\"Office Visit\""
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "]"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              "\n\t\tunion "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "42",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "[",
                                                                                  "\"Encounter, Performed\"",
                                                                                  ": "
                                                                                ]
                                                                              },
                                                                              {
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "\"Annual Wellness Visit\""
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "]"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          "\n\t\tunion "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "44",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "[",
                                                                              "\"Encounter, Performed\"",
                                                                              ": "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "\"Preventive Care Services - Established Office Visit, 18 and Up\""
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              "]"
                                                                            ]
                                                                          }
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      "\n\t\tunion "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "46",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "[",
                                                                          "\"Encounter, Performed\"",
                                                                          ": "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "\"Preventive Care Services-Initial Office Visit, 18 and Up\""
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          "]"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "\n\t\tunion "
                                                                ]
                                                              },
                                                              {
                                                                "r": "48",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "[",
                                                                      "\"Encounter, Performed\"",
                                                                      ": "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "\"Home Healthcare Services\""
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      "]"
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "\n\t\tunion "
                                                            ]
                                                          },
                                                          {
                                                            "r": "50",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "[",
                                                                  "\"Encounter, Performed\"",
                                                                  ": "
                                                                ]
                                                              },
                                                              {
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "\"Care Services in Long-Term Residential Facility\""
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "]"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          "\n\t\tunion "
                                                        ]
                                                      },
                                                      {
                                                        "r": "52",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "[",
                                                              "\"Encounter, Performed\"",
                                                              ": "
                                                            ]
                                                          },
                                                          {
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "\"Nursing Facility Visit\""
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "]"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "\n\t\tunion "
                                                    ]
                                                  },
                                                  {
                                                    "r": "54",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "[",
                                                          "\"Encounter, Performed\"",
                                                          ": "
                                                        ]
                                                      },
                                                      {
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "\"Discharge Services - Nursing Facility\""
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          "]"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " )"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              " ",
                                              "ValidEncounter"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "\n\t\t"
                                    ]
                                  },
                                  {
                                    "r": "60",
                                    "s": [
                                      {
                                        "value": [
                                          "where "
                                        ]
                                      },
                                      {
                                        "r": "60",
                                        "s": [
                                          {
                                            "r": "58",
                                            "s": [
                                              {
                                                "r": "57",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "ValidEncounter"
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "."
                                                ]
                                              },
                                              {
                                                "r": "58",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "relevantPeriod"
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              " ",
                                              "during",
                                              " "
                                            ]
                                          },
                                          {
                                            "r": "59",
                                            "s": [
                                              {
                                                "value": [
                                                  "\"Measurement Period\""
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "61",
                        "locator": "46:2-54:65",
                        "type": "Query",
                        "source": [
                          {
                            "localId": "56",
                            "locator": "46:2-53:90",
                            "alias": "ValidEncounter",
                            "expression": {
                              "localId": "55",
                              "locator": "46:2-53:75",
                              "type": "Union",
                              "operand": [
                                {
                                  "localId": "53",
                                  "locator": "46:4-52:58",
                                  "type": "Union",
                                  "operand": [
                                    {
                                      "localId": "51",
                                      "locator": "46:4-51:83",
                                      "type": "Union",
                                      "operand": [
                                        {
                                          "localId": "49",
                                          "locator": "46:4-50:60",
                                          "type": "Union",
                                          "operand": [
                                            {
                                              "localId": "47",
                                              "locator": "46:4-49:92",
                                              "type": "Union",
                                              "operand": [
                                                {
                                                  "localId": "45",
                                                  "locator": "46:4-48:98",
                                                  "type": "Union",
                                                  "operand": [
                                                    {
                                                      "localId": "43",
                                                      "locator": "46:4-47:57",
                                                      "type": "Union",
                                                      "operand": [
                                                        {
                                                          "localId": "41",
                                                          "locator": "46:4-46:43",
                                                          "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                                          "templateId": "PositiveEncounterPerformed",
                                                          "codeProperty": "code",
                                                          "type": "Retrieve",
                                                          "codes": {
                                                            "name": "Office Visit",
                                                            "type": "ValueSetRef"
                                                          }
                                                        },
                                                        {
                                                          "localId": "42",
                                                          "locator": "47:9-47:57",
                                                          "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                                          "templateId": "PositiveEncounterPerformed",
                                                          "codeProperty": "code",
                                                          "type": "Retrieve",
                                                          "codes": {
                                                            "name": "Annual Wellness Visit",
                                                            "type": "ValueSetRef"
                                                          }
                                                        }
                                                      ]
                                                    },
                                                    {
                                                      "localId": "44",
                                                      "locator": "48:9-48:98",
                                                      "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                                      "templateId": "PositiveEncounterPerformed",
                                                      "codeProperty": "code",
                                                      "type": "Retrieve",
                                                      "codes": {
                                                        "name": "Preventive Care Services - Established Office Visit, 18 and Up",
                                                        "type": "ValueSetRef"
                                                      }
                                                    }
                                                  ]
                                                },
                                                {
                                                  "localId": "46",
                                                  "locator": "49:9-49:92",
                                                  "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                                  "templateId": "PositiveEncounterPerformed",
                                                  "codeProperty": "code",
                                                  "type": "Retrieve",
                                                  "codes": {
                                                    "name": "Preventive Care Services-Initial Office Visit, 18 and Up",
                                                    "type": "ValueSetRef"
                                                  }
                                                }
                                              ]
                                            },
                                            {
                                              "localId": "48",
                                              "locator": "50:9-50:60",
                                              "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                              "templateId": "PositiveEncounterPerformed",
                                              "codeProperty": "code",
                                              "type": "Retrieve",
                                              "codes": {
                                                "name": "Home Healthcare Services",
                                                "type": "ValueSetRef"
                                              }
                                            }
                                          ]
                                        },
                                        {
                                          "localId": "50",
                                          "locator": "51:9-51:83",
                                          "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                          "templateId": "PositiveEncounterPerformed",
                                          "codeProperty": "code",
                                          "type": "Retrieve",
                                          "codes": {
                                            "name": "Care Services in Long-Term Residential Facility",
                                            "type": "ValueSetRef"
                                          }
                                        }
                                      ]
                                    },
                                    {
                                      "localId": "52",
                                      "locator": "52:9-52:58",
                                      "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                      "templateId": "PositiveEncounterPerformed",
                                      "codeProperty": "code",
                                      "type": "Retrieve",
                                      "codes": {
                                        "name": "Nursing Facility Visit",
                                        "type": "ValueSetRef"
                                      }
                                    }
                                  ]
                                },
                                {
                                  "localId": "54",
                                  "locator": "53:9-53:73",
                                  "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                  "templateId": "PositiveEncounterPerformed",
                                  "codeProperty": "code",
                                  "type": "Retrieve",
                                  "codes": {
                                    "name": "Discharge Services - Nursing Facility",
                                    "type": "ValueSetRef"
                                  }
                                }
                              ]
                            }
                          }
                        ],
                        "relationship": [
        
                        ],
                        "where": {
                          "localId": "60",
                          "locator": "54:3-54:65",
                          "type": "IncludedIn",
                          "operand": [
                            {
                              "localId": "58",
                              "locator": "54:9-54:37",
                              "path": "relevantPeriod",
                              "scope": "ValidEncounter",
                              "type": "Property"
                            },
                            {
                              "localId": "59",
                              "locator": "54:46-54:65",
                              "name": "Measurement Period",
                              "type": "ParameterRef"
                            }
                          ]
                        }
                      }
                    },
                    {
                      "localId": "66",
                      "locator": "67:1-71:36",
                      "name": "Initial Population",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "66",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Initial Population\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "65",
                                "s": [
                                  {
                                    "r": "40",
                                    "s": [
                                      {
                                        "value": [
                                          "exists "
                                        ]
                                      },
                                      {
                                        "r": "39",
                                        "s": [
                                          {
                                            "value": [
                                              "( "
                                            ]
                                          },
                                          {
                                            "r": "39",
                                            "s": [
                                              {
                                                "s": [
                                                  {
                                                    "r": "30",
                                                    "s": [
                                                      {
                                                        "r": "29",
                                                        "s": [
                                                          {
                                                            "r": "29",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "[",
                                                                  "\"Patient Characteristic Birthdate\"",
                                                                  "]"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "BirthDate"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t\t\t"
                                                ]
                                              },
                                              {
                                                "r": "38",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "where "
                                                    ]
                                                  },
                                                  {
                                                    "r": "38",
                                                    "s": [
                                                      {
                                                        "r": "36",
                                                        "s": [
                                                          {
                                                            "r": "31",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "Global"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "36",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "\"CalendarAgeInYearsAt\"",
                                                                  "("
                                                                ]
                                                              },
                                                              {
                                                                "r": "33",
                                                                "s": [
                                                                  {
                                                                    "r": "32",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "BirthDate"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      "."
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "33",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "birthDatetime"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  ", "
                                                                ]
                                                              },
                                                              {
                                                                "r": "35",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "start of "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "34",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "\"Measurement Period\""
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  ")"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          ">=",
                                                          " ",
                                                          "65"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "\n\t)"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "\n\t\tand "
                                    ]
                                  },
                                  {
                                    "r": "64",
                                    "s": [
                                      {
                                        "value": [
                                          "exists "
                                        ]
                                      },
                                      {
                                        "r": "63",
                                        "s": [
                                          {
                                            "value": [
                                              "\"Qualifying Encounters\""
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "65",
                        "locator": "68:2-71:36",
                        "type": "And",
                        "operand": [
                          {
                            "localId": "40",
                            "locator": "68:2-70:2",
                            "type": "Exists",
                            "operand": {
                              "localId": "39",
                              "locator": "68:9-70:2",
                              "type": "Query",
                              "source": [
                                {
                                  "localId": "30",
                                  "locator": "68:11-68:56",
                                  "alias": "BirthDate",
                                  "expression": {
                                    "localId": "29",
                                    "locator": "68:11-68:46",
                                    "dataType": "{urn:healthit-gov:qdm:v5_3}PatientCharacteristicBirthdate",
                                    "type": "Retrieve"
                                  }
                                }
                              ],
                              "relationship": [
        
                              ],
                              "where": {
                                "localId": "38",
                                "locator": "69:4-69:99",
                                "type": "GreaterOrEqual",
                                "operand": [
                                  {
                                    "localId": "36",
                                    "locator": "69:10-69:94",
                                    "name": "CalendarAgeInYearsAt",
                                    "libraryName": "Global",
                                    "type": "FunctionRef",
                                    "operand": [
                                      {
                                        "localId": "33",
                                        "locator": "69:40-69:62",
                                        "path": "birthDatetime",
                                        "scope": "BirthDate",
                                        "type": "Property"
                                      },
                                      {
                                        "localId": "35",
                                        "locator": "69:65-69:93",
                                        "type": "Start",
                                        "operand": {
                                          "localId": "34",
                                          "locator": "69:74-69:93",
                                          "name": "Measurement Period",
                                          "type": "ParameterRef"
                                        }
                                      }
                                    ]
                                  },
                                  {
                                    "localId": "37",
                                    "locator": "69:98-69:99",
                                    "valueType": "{urn:hl7-org:elm-types:r1}Integer",
                                    "value": "65",
                                    "type": "Literal"
                                  }
                                ]
                              }
                            }
                          },
                          {
                            "localId": "64",
                            "locator": "71:7-71:36",
                            "type": "Exists",
                            "operand": {
                              "localId": "63",
                              "locator": "71:14-71:36",
                              "name": "Qualifying Encounters",
                              "type": "ExpressionRef"
                            }
                          }
                        ]
                      }
                    },
                    {
                      "localId": "68",
                      "locator": "42:1-43:21",
                      "name": "Denominator",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "68",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Denominator\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "67",
                                "s": [
                                  {
                                    "value": [
                                      "\"Initial Population\""
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "67",
                        "locator": "43:2-43:21",
                        "name": "Initial Population",
                        "type": "ExpressionRef"
                      }
                    },
                    {
                      "localId": "88",
                      "locator": "56:1-62:3",
                      "name": "Numerator",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "88",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Numerator\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "87",
                                "s": [
                                  {
                                    "r": "77",
                                    "s": [
                                      {
                                        "value": [
                                          "exists "
                                        ]
                                      },
                                      {
                                        "r": "76",
                                        "s": [
                                          {
                                            "value": [
                                              "( "
                                            ]
                                          },
                                          {
                                            "r": "76",
                                            "s": [
                                              {
                                                "s": [
                                                  {
                                                    "r": "70",
                                                    "s": [
                                                      {
                                                        "r": "69",
                                                        "s": [
                                                          {
                                                            "r": "69",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "[",
                                                                  "\"Immunization, Administered\"",
                                                                  ": "
                                                                ]
                                                              },
                                                              {
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "\"Pneumococcal Vaccine\""
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "]"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "PneumococcalVaccine"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t\t\t"
                                                ]
                                              },
                                              {
                                                "r": "75",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "where "
                                                    ]
                                                  },
                                                  {
                                                    "r": "75",
                                                    "s": [
                                                      {
                                                        "r": "72",
                                                        "s": [
                                                          {
                                                            "r": "71",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "PneumococcalVaccine"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "72",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "authorDatetime"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "on or before",
                                                          " "
                                                        ]
                                                      },
                                                      {
                                                        "r": "74",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "end of "
                                                            ]
                                                          },
                                                          {
                                                            "r": "73",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "\"Measurement Period\""
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "\n\t)"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "\n\t\tor "
                                    ]
                                  },
                                  {
                                    "r": "86",
                                    "s": [
                                      {
                                        "value": [
                                          "exists "
                                        ]
                                      },
                                      {
                                        "r": "85",
                                        "s": [
                                          {
                                            "value": [
                                              "( "
                                            ]
                                          },
                                          {
                                            "r": "85",
                                            "s": [
                                              {
                                                "s": [
                                                  {
                                                    "r": "79",
                                                    "s": [
                                                      {
                                                        "r": "78",
                                                        "s": [
                                                          {
                                                            "r": "78",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "[",
                                                                  "\"Procedure, Performed\"",
                                                                  ": "
                                                                ]
                                                              },
                                                              {
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "\"Pneumococcal Vaccine Administered\""
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "]"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "PneumococcalVaccineGiven"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t\t\t\t"
                                                ]
                                              },
                                              {
                                                "r": "84",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "where "
                                                    ]
                                                  },
                                                  {
                                                    "r": "84",
                                                    "s": [
                                                      {
                                                        "r": "81",
                                                        "s": [
                                                          {
                                                            "r": "80",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "PneumococcalVaccineGiven"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "81",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "relevantPeriod"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "starts on or before",
                                                          " "
                                                        ]
                                                      },
                                                      {
                                                        "r": "83",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "end of "
                                                            ]
                                                          },
                                                          {
                                                            "r": "82",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "\"Measurement Period\""
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "\n\t\t)"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "87",
                        "locator": "57:2-62:3",
                        "type": "Or",
                        "operand": [
                          {
                            "localId": "77",
                            "locator": "57:2-59:2",
                            "type": "Exists",
                            "operand": {
                              "localId": "76",
                              "locator": "57:9-59:2",
                              "type": "Query",
                              "source": [
                                {
                                  "localId": "70",
                                  "locator": "57:11-57:84",
                                  "alias": "PneumococcalVaccine",
                                  "expression": {
                                    "localId": "69",
                                    "locator": "57:11-57:64",
                                    "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveImmunizationAdministered",
                                    "templateId": "PositiveImmunizationAdministered",
                                    "codeProperty": "code",
                                    "type": "Retrieve",
                                    "codes": {
                                      "name": "Pneumococcal Vaccine",
                                      "type": "ValueSetRef"
                                    }
                                  }
                                }
                              ],
                              "relationship": [
        
                              ],
                              "where": {
                                "localId": "75",
                                "locator": "58:4-58:84",
                                "type": "SameOrBefore",
                                "operand": [
                                  {
                                    "localId": "72",
                                    "locator": "58:10-58:43",
                                    "path": "authorDatetime",
                                    "scope": "PneumococcalVaccine",
                                    "type": "Property"
                                  },
                                  {
                                    "localId": "74",
                                    "locator": "58:58-58:84",
                                    "type": "End",
                                    "operand": {
                                      "localId": "73",
                                      "locator": "58:65-58:84",
                                      "name": "Measurement Period",
                                      "type": "ParameterRef"
                                    }
                                  }
                                ]
                              }
                            }
                          },
                          {
                            "localId": "86",
                            "locator": "60:6-62:3",
                            "type": "Exists",
                            "operand": {
                              "localId": "85",
                              "locator": "60:13-62:3",
                              "type": "Query",
                              "source": [
                                {
                                  "localId": "79",
                                  "locator": "60:15-60:100",
                                  "alias": "PneumococcalVaccineGiven",
                                  "expression": {
                                    "localId": "78",
                                    "locator": "60:15-60:75",
                                    "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveProcedurePerformed",
                                    "templateId": "PositiveProcedurePerformed",
                                    "codeProperty": "code",
                                    "type": "Retrieve",
                                    "codes": {
                                      "name": "Pneumococcal Vaccine Administered",
                                      "type": "ValueSetRef"
                                    }
                                  }
                                }
                              ],
                              "relationship": [
        
                              ],
                              "where": {
                                "localId": "84",
                                "locator": "61:5-61:97",
                                "type": "SameOrBefore",
                                "operand": [
                                  {
                                    "locator": "61:51-61:56",
                                    "type": "Start",
                                    "operand": {
                                      "localId": "81",
                                      "locator": "61:11-61:49",
                                      "path": "relevantPeriod",
                                      "scope": "PneumococcalVaccineGiven",
                                      "type": "Property"
                                    }
                                  },
                                  {
                                    "localId": "83",
                                    "locator": "61:71-61:97",
                                    "type": "End",
                                    "operand": {
                                      "localId": "82",
                                      "locator": "61:78-61:97",
                                      "name": "Measurement Period",
                                      "type": "ParameterRef"
                                    }
                                  }
                                ]
                              }
                            }
                          }
                        ]
                      }
                    },
                    {
                      "localId": "91",
                      "locator": "64:1-65:22",
                      "name": "Denominator Exclusions",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "91",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Denominator Exclusions\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "90",
                                "s": [
                                  {
                                    "r": "89",
                                    "s": [
                                      {
                                        "value": [
                                          "Hospice"
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "."
                                    ]
                                  },
                                  {
                                    "r": "90",
                                    "s": [
                                      {
                                        "value": [
                                          "\"Has Hospice\""
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "90",
                        "locator": "65:2-65:22",
                        "name": "Has Hospice",
                        "libraryName": "Hospice",
                        "type": "ExpressionRef"
                      }
                    }
                  ]
                }
              }
            },
            {
              "library": {
                "identifier": {
                  "id": "MATGlobalCommonFunctions",
                  "version": "2.0.000"
                },
                "schemaIdentifier": {
                  "id": "urn:hl7-org:elm",
                  "version": "r1"
                },
                "usings": {
                  "def": [
                    {
                      "localIdentifier": "System",
                      "uri": "urn:hl7-org:elm-types:r1"
                    },
                    {
                      "localId": "1",
                      "locator": "3:1-3:23",
                      "localIdentifier": "QDM",
                      "uri": "urn:healthit-gov:qdm:v5_3",
                      "version": "5.3"
                    }
                  ]
                },
                "parameters": {
                  "def": [
                    {
                      "localId": "13",
                      "locator": "15:1-15:49",
                      "name": "Measurement Period",
                      "accessLevel": "Public",
                      "parameterTypeSpecifier": {
                        "localId": "12",
                        "locator": "15:32-15:49",
                        "type": "IntervalTypeSpecifier",
                        "pointType": {
                          "localId": "11",
                          "locator": "15:41-15:48",
                          "name": "{urn:hl7-org:elm-types:r1}DateTime",
                          "type": "NamedTypeSpecifier"
                        }
                      }
                    }
                  ]
                },
                "codeSystems": {
                  "def": [
                    {
                      "localId": "2",
                      "locator": "5:1-5:87",
                      "name": "LOINC:2.46",
                      "id": "LOINC",
                      "version": "urn:hl7:version:2.46",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "3",
                      "locator": "6:1-6:97",
                      "name": "SNOMEDCT:2016-03",
                      "id": "SNOMED-CT",
                      "version": "urn:hl7:version:2016-03",
                      "accessLevel": "Public"
                    }
                  ]
                },
                "valueSets": {
                  "def": [
                    {
                      "localId": "4",
                      "locator": "8:1-8:82",
                      "name": "Emergency Department Visit",
                      "id": "2.16.840.1.113883.3.117.1.7.1.292",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "5",
                      "locator": "9:1-9:71",
                      "name": "Encounter Inpatient",
                      "id": "2.16.840.1.113883.3.666.5.307",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "6",
                      "locator": "10:1-10:71",
                      "name": "Intensive Care Unit",
                      "id": "2.16.840.1.113762.1.4.1110.23",
                      "accessLevel": "Public"
                    }
                  ]
                },
                "codes": {
                  "def": [
                    {
                      "localId": "8",
                      "locator": "12:1-12:66",
                      "name": "Birthdate",
                      "id": "21112-8",
                      "display": "Birth date",
                      "accessLevel": "Public",
                      "codeSystem": {
                        "localId": "7",
                        "locator": "12:34-12:45",
                        "name": "LOINC:2.46"
                      }
                    },
                    {
                      "localId": "10",
                      "locator": "13:1-13:63",
                      "name": "Dead",
                      "id": "419099009",
                      "display": "Dead",
                      "accessLevel": "Public",
                      "codeSystem": {
                        "localId": "9",
                        "locator": "13:31-13:48",
                        "name": "SNOMEDCT:2016-03"
                      }
                    }
                  ]
                },
                "statements": {
                  "def": [
                    {
                      "locator": "17:1-17:15",
                      "name": "Patient",
                      "context": "Patient",
                      "expression": {
                        "type": "SingletonFrom",
                        "operand": {
                          "locator": "17:1-17:15",
                          "dataType": "{urn:healthit-gov:qdm:v5_3}Patient",
                          "templateId": "Patient",
                          "type": "Retrieve"
                        }
                      }
                    },
                    {
                      "localId": "15",
                      "locator": "19:1-20:55",
                      "name": "Encounter",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "15",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Encounter\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "14",
                                "s": [
                                  {
                                    "value": [
                                      "[",
                                      "\"Encounter, Performed\"",
                                      ": "
                                    ]
                                  },
                                  {
                                    "s": [
                                      {
                                        "value": [
                                          "\"Emergency Department Visit\""
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "]"
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "14",
                        "locator": "20:2-20:55",
                        "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                        "templateId": "PositiveEncounterPerformed",
                        "codeProperty": "code",
                        "type": "Retrieve",
                        "codes": {
                          "name": "Emergency Department Visit",
                          "type": "ValueSetRef"
                        }
                      }
                    },
                    {
                      "localId": "27",
                      "locator": "63:1-64:59",
                      "name": "LengthInDays",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "27",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"LengthInDays\"",
                                  "(",
                                  "Value",
                                  " "
                                ]
                              },
                              {
                                "r": "21",
                                "s": [
                                  {
                                    "value": [
                                      "Interval<"
                                    ]
                                  },
                                  {
                                    "r": "20",
                                    "s": [
                                      {
                                        "value": [
                                          "DateTime"
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      ">"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "26",
                                "s": [
                                  {
                                    "r": "26",
                                    "s": [
                                      {
                                        "value": [
                                          "difference in days between "
                                        ]
                                      },
                                      {
                                        "r": "23",
                                        "s": [
                                          {
                                            "value": [
                                              "start of "
                                            ]
                                          },
                                          {
                                            "r": "22",
                                            "s": [
                                              {
                                                "value": [
                                                  "Value"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          " and "
                                        ]
                                      },
                                      {
                                        "r": "25",
                                        "s": [
                                          {
                                            "value": [
                                              "end of "
                                            ]
                                          },
                                          {
                                            "r": "24",
                                            "s": [
                                              {
                                                "value": [
                                                  "Value"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "26",
                        "locator": "64:2-64:59",
                        "precision": "Day",
                        "type": "DifferenceBetween",
                        "operand": [
                          {
                            "localId": "23",
                            "locator": "64:29-64:42",
                            "type": "Start",
                            "operand": {
                              "localId": "22",
                              "locator": "64:38-64:42",
                              "name": "Value",
                              "type": "OperandRef"
                            }
                          },
                          {
                            "localId": "25",
                            "locator": "64:48-64:59",
                            "type": "End",
                            "operand": {
                              "localId": "24",
                              "locator": "64:55-64:59",
                              "name": "Value",
                              "type": "OperandRef"
                            }
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "Value",
                          "operandTypeSpecifier": {
                            "localId": "21",
                            "locator": "63:38-63:55",
                            "type": "IntervalTypeSpecifier",
                            "pointType": {
                              "localId": "20",
                              "locator": "63:47-63:54",
                              "name": "{urn:hl7-org:elm-types:r1}DateTime",
                              "type": "NamedTypeSpecifier"
                            }
                          }
                        }
                      ]
                    },
                    {
                      "localId": "37",
                      "locator": "22:1-25:73",
                      "name": "Inpatient Encounter",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "37",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Inpatient Encounter\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "36",
                                "s": [
                                  {
                                    "s": [
                                      {
                                        "r": "17",
                                        "s": [
                                          {
                                            "r": "16",
                                            "s": [
                                              {
                                                "r": "16",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "[",
                                                      "\"Encounter, Performed\"",
                                                      ": "
                                                    ]
                                                  },
                                                  {
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "\"Encounter Inpatient\""
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "]"
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              " ",
                                              "EncounterInpatient"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "\n\t\t"
                                    ]
                                  },
                                  {
                                    "r": "35",
                                    "s": [
                                      {
                                        "value": [
                                          "where "
                                        ]
                                      },
                                      {
                                        "r": "35",
                                        "s": [
                                          {
                                            "r": "30",
                                            "s": [
                                              {
                                                "r": "28",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "\"LengthInDays\"",
                                                      "("
                                                    ]
                                                  },
                                                  {
                                                    "r": "19",
                                                    "s": [
                                                      {
                                                        "r": "18",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "EncounterInpatient"
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          "."
                                                        ]
                                                      },
                                                      {
                                                        "r": "19",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "relevantPeriod"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      ")"
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "<=",
                                                  " ",
                                                  "120"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "\n\t\t\tand "
                                            ]
                                          },
                                          {
                                            "r": "34",
                                            "s": [
                                              {
                                                "r": "32",
                                                "s": [
                                                  {
                                                    "r": "31",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "EncounterInpatient"
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "."
                                                    ]
                                                  },
                                                  {
                                                    "r": "32",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "relevantPeriod"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " ",
                                                  "ends during",
                                                  " "
                                                ]
                                              },
                                              {
                                                "r": "33",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "\"Measurement Period\""
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "36",
                        "locator": "23:2-25:73",
                        "type": "Query",
                        "source": [
                          {
                            "localId": "17",
                            "locator": "23:2-23:67",
                            "alias": "EncounterInpatient",
                            "expression": {
                              "localId": "16",
                              "locator": "23:2-23:48",
                              "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                              "templateId": "PositiveEncounterPerformed",
                              "codeProperty": "code",
                              "type": "Retrieve",
                              "codes": {
                                "name": "Encounter Inpatient",
                                "type": "ValueSetRef"
                              }
                            }
                          }
                        ],
                        "relationship": [
        
                        ],
                        "where": {
                          "localId": "35",
                          "locator": "24:3-25:73",
                          "type": "And",
                          "operand": [
                            {
                              "localId": "30",
                              "locator": "24:9-24:63",
                              "type": "LessOrEqual",
                              "operand": [
                                {
                                  "localId": "28",
                                  "locator": "24:9-24:57",
                                  "name": "LengthInDays",
                                  "type": "FunctionRef",
                                  "operand": [
                                    {
                                      "localId": "19",
                                      "locator": "24:24-24:56",
                                      "path": "relevantPeriod",
                                      "scope": "EncounterInpatient",
                                      "type": "Property"
                                    }
                                  ]
                                },
                                {
                                  "localId": "29",
                                  "locator": "24:61-24:63",
                                  "valueType": "{urn:hl7-org:elm-types:r1}Integer",
                                  "value": "120",
                                  "type": "Literal"
                                }
                              ]
                            },
                            {
                              "localId": "34",
                              "locator": "25:8-25:73",
                              "type": "In",
                              "operand": [
                                {
                                  "locator": "25:42-25:45",
                                  "type": "End",
                                  "operand": {
                                    "localId": "32",
                                    "locator": "25:8-25:40",
                                    "path": "relevantPeriod",
                                    "scope": "EncounterInpatient",
                                    "type": "Property"
                                  }
                                },
                                {
                                  "localId": "33",
                                  "locator": "25:54-25:73",
                                  "name": "Measurement Period",
                                  "type": "ParameterRef"
                                }
                              ]
                            }
                          ]
                        }
                      }
                    },
                    {
                      "localId": "52",
                      "locator": "28:1-29:93",
                      "name": "ToDate",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "52",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"ToDate\"",
                                  "(",
                                  "Value",
                                  " "
                                ]
                              },
                              {
                                "r": "38",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "51",
                                "s": [
                                  {
                                    "r": "51",
                                    "s": [
                                      {
                                        "value": [
                                          "DateTime",
                                          "("
                                        ]
                                      },
                                      {
                                        "r": "40",
                                        "s": [
                                          {
                                            "value": [
                                              "year from "
                                            ]
                                          },
                                          {
                                            "r": "39",
                                            "s": [
                                              {
                                                "value": [
                                                  "Value"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ", "
                                        ]
                                      },
                                      {
                                        "r": "42",
                                        "s": [
                                          {
                                            "value": [
                                              "month from "
                                            ]
                                          },
                                          {
                                            "r": "41",
                                            "s": [
                                              {
                                                "value": [
                                                  "Value"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ", "
                                        ]
                                      },
                                      {
                                        "r": "44",
                                        "s": [
                                          {
                                            "value": [
                                              "day from "
                                            ]
                                          },
                                          {
                                            "r": "43",
                                            "s": [
                                              {
                                                "value": [
                                                  "Value"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ", ",
                                          "0",
                                          ", ",
                                          "0",
                                          ", ",
                                          "0",
                                          ", ",
                                          "0",
                                          ", "
                                        ]
                                      },
                                      {
                                        "r": "50",
                                        "s": [
                                          {
                                            "value": [
                                              "timezone from "
                                            ]
                                          },
                                          {
                                            "r": "49",
                                            "s": [
                                              {
                                                "value": [
                                                  "Value"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ")"
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "51",
                        "locator": "29:2-29:93",
                        "type": "DateTime",
                        "year": {
                          "localId": "40",
                          "locator": "29:11-29:25",
                          "precision": "Year",
                          "type": "DateTimeComponentFrom",
                          "operand": {
                            "localId": "39",
                            "locator": "29:21-29:25",
                            "name": "Value",
                            "type": "OperandRef"
                          }
                        },
                        "month": {
                          "localId": "42",
                          "locator": "29:28-29:43",
                          "precision": "Month",
                          "type": "DateTimeComponentFrom",
                          "operand": {
                            "localId": "41",
                            "locator": "29:39-29:43",
                            "name": "Value",
                            "type": "OperandRef"
                          }
                        },
                        "day": {
                          "localId": "44",
                          "locator": "29:46-29:59",
                          "precision": "Day",
                          "type": "DateTimeComponentFrom",
                          "operand": {
                            "localId": "43",
                            "locator": "29:55-29:59",
                            "name": "Value",
                            "type": "OperandRef"
                          }
                        },
                        "hour": {
                          "localId": "45",
                          "locator": "29:62",
                          "valueType": "{urn:hl7-org:elm-types:r1}Integer",
                          "value": "0",
                          "type": "Literal"
                        },
                        "minute": {
                          "localId": "46",
                          "locator": "29:65",
                          "valueType": "{urn:hl7-org:elm-types:r1}Integer",
                          "value": "0",
                          "type": "Literal"
                        },
                        "second": {
                          "localId": "47",
                          "locator": "29:68",
                          "valueType": "{urn:hl7-org:elm-types:r1}Integer",
                          "value": "0",
                          "type": "Literal"
                        },
                        "millisecond": {
                          "localId": "48",
                          "locator": "29:71",
                          "valueType": "{urn:hl7-org:elm-types:r1}Integer",
                          "value": "0",
                          "type": "Literal"
                        },
                        "timezoneOffset": {
                          "localId": "50",
                          "locator": "29:74-29:92",
                          "type": "TimezoneFrom",
                          "operand": {
                            "localId": "49",
                            "locator": "29:88-29:92",
                            "name": "Value",
                            "type": "OperandRef"
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Value",
                          "operandTypeSpecifier": {
                            "localId": "38",
                            "locator": "28:32-28:39",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "60",
                      "locator": "32:1-33:51",
                      "name": "CalendarAgeInDaysAt",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "60",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"CalendarAgeInDaysAt\"",
                                  "(",
                                  "BirthDateTime",
                                  " "
                                ]
                              },
                              {
                                "r": "53",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  ", ",
                                  "AsOf",
                                  " "
                                ]
                              },
                              {
                                "r": "54",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "59",
                                "s": [
                                  {
                                    "r": "59",
                                    "s": [
                                      {
                                        "value": [
                                          "days between "
                                        ]
                                      },
                                      {
                                        "r": "56",
                                        "s": [
                                          {
                                            "value": [
                                              "ToDate",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "55",
                                            "s": [
                                              {
                                                "value": [
                                                  "BirthDateTime"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          "and "
                                        ]
                                      },
                                      {
                                        "r": "58",
                                        "s": [
                                          {
                                            "value": [
                                              "ToDate",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "57",
                                            "s": [
                                              {
                                                "value": [
                                                  "AsOf"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "59",
                        "locator": "33:2-33:51",
                        "precision": "Day",
                        "type": "DurationBetween",
                        "operand": [
                          {
                            "localId": "56",
                            "locator": "33:15-33:35",
                            "name": "ToDate",
                            "type": "FunctionRef",
                            "operand": [
                              {
                                "localId": "55",
                                "locator": "33:22-33:34",
                                "name": "BirthDateTime",
                                "type": "OperandRef"
                              }
                            ]
                          },
                          {
                            "localId": "58",
                            "locator": "33:40-33:51",
                            "name": "ToDate",
                            "type": "FunctionRef",
                            "operand": [
                              {
                                "localId": "57",
                                "locator": "33:47-33:50",
                                "name": "AsOf",
                                "type": "OperandRef"
                              }
                            ]
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "BirthDateTime",
                          "operandTypeSpecifier": {
                            "localId": "53",
                            "locator": "32:53-32:60",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        },
                        {
                          "name": "AsOf",
                          "operandTypeSpecifier": {
                            "localId": "54",
                            "locator": "32:68-32:75",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "65",
                      "locator": "36:1-37:44",
                      "name": "CalendarAgeInDays",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "65",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"CalendarAgeInDays\"",
                                  "(",
                                  "BirthDateTime",
                                  " "
                                ]
                              },
                              {
                                "r": "61",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "64",
                                "s": [
                                  {
                                    "r": "64",
                                    "s": [
                                      {
                                        "value": [
                                          "CalendarAgeInDaysAt",
                                          "("
                                        ]
                                      },
                                      {
                                        "r": "62",
                                        "s": [
                                          {
                                            "value": [
                                              "BirthDateTime"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ", "
                                        ]
                                      },
                                      {
                                        "r": "63",
                                        "s": [
                                          {
                                            "value": [
                                              "Today",
                                              "()"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ")"
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "64",
                        "locator": "37:2-37:44",
                        "name": "CalendarAgeInDaysAt",
                        "type": "FunctionRef",
                        "operand": [
                          {
                            "localId": "62",
                            "locator": "37:22-37:34",
                            "name": "BirthDateTime",
                            "type": "OperandRef"
                          },
                          {
                            "localId": "63",
                            "locator": "37:37-37:43",
                            "type": "Today"
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "BirthDateTime",
                          "operandTypeSpecifier": {
                            "localId": "61",
                            "locator": "36:51-36:58",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "73",
                      "locator": "40:1-41:53",
                      "name": "CalendarAgeInMonthsAt",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "73",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"CalendarAgeInMonthsAt\"",
                                  "(",
                                  "BirthDateTime",
                                  " "
                                ]
                              },
                              {
                                "r": "66",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  ", ",
                                  "AsOf",
                                  " "
                                ]
                              },
                              {
                                "r": "67",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "72",
                                "s": [
                                  {
                                    "r": "72",
                                    "s": [
                                      {
                                        "value": [
                                          "months between "
                                        ]
                                      },
                                      {
                                        "r": "69",
                                        "s": [
                                          {
                                            "value": [
                                              "ToDate",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "68",
                                            "s": [
                                              {
                                                "value": [
                                                  "BirthDateTime"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          "and "
                                        ]
                                      },
                                      {
                                        "r": "71",
                                        "s": [
                                          {
                                            "value": [
                                              "ToDate",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "70",
                                            "s": [
                                              {
                                                "value": [
                                                  "AsOf"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "72",
                        "locator": "41:2-41:53",
                        "precision": "Month",
                        "type": "DurationBetween",
                        "operand": [
                          {
                            "localId": "69",
                            "locator": "41:17-41:37",
                            "name": "ToDate",
                            "type": "FunctionRef",
                            "operand": [
                              {
                                "localId": "68",
                                "locator": "41:24-41:36",
                                "name": "BirthDateTime",
                                "type": "OperandRef"
                              }
                            ]
                          },
                          {
                            "localId": "71",
                            "locator": "41:42-41:53",
                            "name": "ToDate",
                            "type": "FunctionRef",
                            "operand": [
                              {
                                "localId": "70",
                                "locator": "41:49-41:52",
                                "name": "AsOf",
                                "type": "OperandRef"
                              }
                            ]
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "BirthDateTime",
                          "operandTypeSpecifier": {
                            "localId": "66",
                            "locator": "40:55-40:62",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        },
                        {
                          "name": "AsOf",
                          "operandTypeSpecifier": {
                            "localId": "67",
                            "locator": "40:70-40:77",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "78",
                      "locator": "44:1-45:46",
                      "name": "CalendarAgeInMonths",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "78",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"CalendarAgeInMonths\"",
                                  "(",
                                  "BirthDateTime",
                                  " "
                                ]
                              },
                              {
                                "r": "74",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "77",
                                "s": [
                                  {
                                    "r": "77",
                                    "s": [
                                      {
                                        "value": [
                                          "CalendarAgeInMonthsAt",
                                          "("
                                        ]
                                      },
                                      {
                                        "r": "75",
                                        "s": [
                                          {
                                            "value": [
                                              "BirthDateTime"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ", "
                                        ]
                                      },
                                      {
                                        "r": "76",
                                        "s": [
                                          {
                                            "value": [
                                              "Today",
                                              "()"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ")"
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "77",
                        "locator": "45:2-45:46",
                        "name": "CalendarAgeInMonthsAt",
                        "type": "FunctionRef",
                        "operand": [
                          {
                            "localId": "75",
                            "locator": "45:24-45:36",
                            "name": "BirthDateTime",
                            "type": "OperandRef"
                          },
                          {
                            "localId": "76",
                            "locator": "45:39-45:45",
                            "type": "Today"
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "BirthDateTime",
                          "operandTypeSpecifier": {
                            "localId": "74",
                            "locator": "44:53-44:60",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "86",
                      "locator": "48:1-49:52",
                      "name": "CalendarAgeInYearsAt",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "86",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"CalendarAgeInYearsAt\"",
                                  "(",
                                  "BirthDateTime",
                                  " "
                                ]
                              },
                              {
                                "r": "79",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  ", ",
                                  "AsOf",
                                  " "
                                ]
                              },
                              {
                                "r": "80",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "85",
                                "s": [
                                  {
                                    "r": "85",
                                    "s": [
                                      {
                                        "value": [
                                          "years between "
                                        ]
                                      },
                                      {
                                        "r": "82",
                                        "s": [
                                          {
                                            "value": [
                                              "ToDate",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "81",
                                            "s": [
                                              {
                                                "value": [
                                                  "BirthDateTime"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          "and "
                                        ]
                                      },
                                      {
                                        "r": "84",
                                        "s": [
                                          {
                                            "value": [
                                              "ToDate",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "83",
                                            "s": [
                                              {
                                                "value": [
                                                  "AsOf"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "85",
                        "locator": "49:2-49:52",
                        "precision": "Year",
                        "type": "DurationBetween",
                        "operand": [
                          {
                            "localId": "82",
                            "locator": "49:16-49:36",
                            "name": "ToDate",
                            "type": "FunctionRef",
                            "operand": [
                              {
                                "localId": "81",
                                "locator": "49:23-49:35",
                                "name": "BirthDateTime",
                                "type": "OperandRef"
                              }
                            ]
                          },
                          {
                            "localId": "84",
                            "locator": "49:41-49:52",
                            "name": "ToDate",
                            "type": "FunctionRef",
                            "operand": [
                              {
                                "localId": "83",
                                "locator": "49:48-49:51",
                                "name": "AsOf",
                                "type": "OperandRef"
                              }
                            ]
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "BirthDateTime",
                          "operandTypeSpecifier": {
                            "localId": "79",
                            "locator": "48:54-48:61",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        },
                        {
                          "name": "AsOf",
                          "operandTypeSpecifier": {
                            "localId": "80",
                            "locator": "48:69-48:76",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "91",
                      "locator": "52:1-53:45",
                      "name": "CalendarAgeInYears",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "91",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"CalendarAgeInYears\"",
                                  "(",
                                  "BirthDateTime",
                                  " "
                                ]
                              },
                              {
                                "r": "87",
                                "s": [
                                  {
                                    "value": [
                                      "DateTime"
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "90",
                                "s": [
                                  {
                                    "r": "90",
                                    "s": [
                                      {
                                        "value": [
                                          "CalendarAgeInYearsAt",
                                          "("
                                        ]
                                      },
                                      {
                                        "r": "88",
                                        "s": [
                                          {
                                            "value": [
                                              "BirthDateTime"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ", "
                                        ]
                                      },
                                      {
                                        "r": "89",
                                        "s": [
                                          {
                                            "value": [
                                              "Today",
                                              "()"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ")"
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "90",
                        "locator": "53:2-53:45",
                        "name": "CalendarAgeInYearsAt",
                        "type": "FunctionRef",
                        "operand": [
                          {
                            "localId": "88",
                            "locator": "53:23-53:35",
                            "name": "BirthDateTime",
                            "type": "OperandRef"
                          },
                          {
                            "localId": "89",
                            "locator": "53:38-53:44",
                            "type": "Today"
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "BirthDateTime",
                          "operandTypeSpecifier": {
                            "localId": "87",
                            "locator": "52:52-52:59",
                            "name": "{urn:hl7-org:elm-types:r1}DateTime",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "119",
                      "locator": "56:1-60:125",
                      "name": "Hospitalization",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "119",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Hospitalization\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "92",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "118",
                                "s": [
                                  {
                                    "r": "118",
                                    "s": [
                                      {
                                        "s": [
                                          {
                                            "r": "104",
                                            "s": [
                                              {
                                                "r": "103",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "( "
                                                    ]
                                                  },
                                                  {
                                                    "r": "103",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "singleton from "
                                                        ]
                                                      },
                                                      {
                                                        "r": "102",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "( "
                                                            ]
                                                          },
                                                          {
                                                            "r": "102",
                                                            "s": [
                                                              {
                                                                "s": [
                                                                  {
                                                                    "r": "94",
                                                                    "s": [
                                                                      {
                                                                        "r": "93",
                                                                        "s": [
                                                                          {
                                                                            "r": "93",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "[",
                                                                                  "\"Encounter, Performed\"",
                                                                                  ": "
                                                                                ]
                                                                              },
                                                                              {
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "\"Emergency Department Visit\""
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "]"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " ",
                                                                          "EDVisit"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "\n\t\t\t"
                                                                ]
                                                              },
                                                              {
                                                                "r": "101",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "where "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "101",
                                                                    "s": [
                                                                      {
                                                                        "r": "96",
                                                                        "s": [
                                                                          {
                                                                            "r": "95",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "EDVisit"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              "."
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "96",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "relevantPeriod"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "101",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "ends "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "100",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "1 ",
                                                                                  "hour"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              " or less on or before"
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "99",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "start of "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "98",
                                                                            "s": [
                                                                              {
                                                                                "r": "97",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "Encounter"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "."
                                                                                ]
                                                                              },
                                                                              {
                                                                                "r": "98",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "relevantPeriod"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "\n\t)"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      " )"
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " ",
                                                  "X"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          "\n\t\t"
                                        ]
                                      },
                                      {
                                        "r": "117",
                                        "s": [
                                          {
                                            "value": [
                                              "return "
                                            ]
                                          },
                                          {
                                            "r": "116",
                                            "s": [
                                              {
                                                "value": [
                                                  "if "
                                                ]
                                              },
                                              {
                                                "r": "106",
                                                "s": [
                                                  {
                                                    "r": "105",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "X"
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      " is null"
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " then "
                                                ]
                                              },
                                              {
                                                "r": "108",
                                                "s": [
                                                  {
                                                    "r": "107",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "Encounter"
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "."
                                                    ]
                                                  },
                                                  {
                                                    "r": "108",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "relevantPeriod"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " else "
                                                ]
                                              },
                                              {
                                                "r": "115",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "Interval["
                                                    ]
                                                  },
                                                  {
                                                    "r": "111",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "start of "
                                                        ]
                                                      },
                                                      {
                                                        "r": "110",
                                                        "s": [
                                                          {
                                                            "r": "109",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "X"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "110",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "relevantPeriod"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      ", "
                                                    ]
                                                  },
                                                  {
                                                    "r": "114",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "end of "
                                                        ]
                                                      },
                                                      {
                                                        "r": "113",
                                                        "s": [
                                                          {
                                                            "r": "112",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "Encounter"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "113",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "relevantPeriod"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "]"
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "118",
                        "locator": "57:2-60:125",
                        "type": "Query",
                        "source": [
                          {
                            "localId": "104",
                            "locator": "57:2-59:6",
                            "alias": "X",
                            "expression": {
                              "localId": "103",
                              "locator": "57:2-59:4",
                              "type": "SingletonFrom",
                              "operand": {
                                "localId": "102",
                                "locator": "57:19-59:2",
                                "type": "Query",
                                "source": [
                                  {
                                    "localId": "94",
                                    "locator": "57:21-57:82",
                                    "alias": "EDVisit",
                                    "expression": {
                                      "localId": "93",
                                      "locator": "57:21-57:74",
                                      "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                      "templateId": "PositiveEncounterPerformed",
                                      "codeProperty": "code",
                                      "type": "Retrieve",
                                      "codes": {
                                        "name": "Emergency Department Visit",
                                        "type": "ValueSetRef"
                                      }
                                    }
                                  }
                                ],
                                "relationship": [
        
                                ],
                                "where": {
                                  "localId": "101",
                                  "locator": "58:4-58:98",
                                  "type": "In",
                                  "operand": [
                                    {
                                      "locator": "58:33-58:36",
                                      "type": "End",
                                      "operand": {
                                        "localId": "96",
                                        "locator": "58:10-58:31",
                                        "path": "relevantPeriod",
                                        "scope": "EDVisit",
                                        "type": "Property"
                                      }
                                    },
                                    {
                                      "locator": "58:38-58:51",
                                      "lowClosed": true,
                                      "highClosed": true,
                                      "type": "Interval",
                                      "low": {
                                        "locator": "58:66-58:98",
                                        "type": "Subtract",
                                        "operand": [
                                          {
                                            "localId": "99",
                                            "locator": "58:66-58:98",
                                            "type": "Start",
                                            "operand": {
                                              "localId": "98",
                                              "locator": "58:75-58:98",
                                              "path": "relevantPeriod",
                                              "type": "Property",
                                              "source": {
                                                "localId": "97",
                                                "locator": "58:75-58:83",
                                                "name": "Encounter",
                                                "type": "OperandRef"
                                              }
                                            }
                                          },
                                          {
                                            "localId": "100",
                                            "locator": "58:38-58:43",
                                            "value": 1,
                                            "unit": "hour",
                                            "type": "Quantity"
                                          }
                                        ]
                                      },
                                      "high": {
                                        "localId": "99",
                                        "locator": "58:66-58:98",
                                        "type": "Start",
                                        "operand": {
                                          "localId": "98",
                                          "locator": "58:75-58:98",
                                          "path": "relevantPeriod",
                                          "type": "Property",
                                          "source": {
                                            "localId": "97",
                                            "locator": "58:75-58:83",
                                            "name": "Encounter",
                                            "type": "OperandRef"
                                          }
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            }
                          }
                        ],
                        "relationship": [
        
                        ],
                        "return": {
                          "localId": "117",
                          "locator": "60:3-60:125",
                          "expression": {
                            "localId": "116",
                            "locator": "60:10-60:125",
                            "type": "If",
                            "condition": {
                              "asType": "{urn:hl7-org:elm-types:r1}Boolean",
                              "type": "As",
                              "operand": {
                                "localId": "106",
                                "locator": "60:13-60:21",
                                "type": "IsNull",
                                "operand": {
                                  "localId": "105",
                                  "locator": "60:13",
                                  "name": "X",
                                  "type": "AliasRef"
                                }
                              },
                              "asTypeSpecifier": {
                                "name": "{urn:hl7-org:elm-types:r1}Boolean",
                                "type": "NamedTypeSpecifier"
                              }
                            },
                            "then": {
                              "localId": "108",
                              "locator": "60:28-60:51",
                              "path": "relevantPeriod",
                              "type": "Property",
                              "source": {
                                "localId": "107",
                                "locator": "60:28-60:36",
                                "name": "Encounter",
                                "type": "OperandRef"
                              }
                            },
                            "else": {
                              "localId": "115",
                              "locator": "60:58-60:125",
                              "lowClosed": true,
                              "highClosed": true,
                              "type": "Interval",
                              "low": {
                                "localId": "111",
                                "locator": "60:67-60:91",
                                "type": "Start",
                                "operand": {
                                  "localId": "110",
                                  "locator": "60:76-60:91",
                                  "path": "relevantPeriod",
                                  "scope": "X",
                                  "type": "Property"
                                }
                              },
                              "high": {
                                "localId": "114",
                                "locator": "60:94-60:124",
                                "type": "End",
                                "operand": {
                                  "localId": "113",
                                  "locator": "60:101-60:124",
                                  "path": "relevantPeriod",
                                  "type": "Property",
                                  "source": {
                                    "localId": "112",
                                    "locator": "60:101-60:109",
                                    "name": "Encounter",
                                    "type": "OperandRef"
                                  }
                                }
                              }
                            }
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "92",
                            "locator": "56:45-56:66",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "149",
                      "locator": "67:1-71:140",
                      "name": "Hospitalization Locations",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "149",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Hospitalization Locations\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "123",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "148",
                                "s": [
                                  {
                                    "r": "148",
                                    "s": [
                                      {
                                        "s": [
                                          {
                                            "r": "135",
                                            "s": [
                                              {
                                                "r": "134",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "( "
                                                    ]
                                                  },
                                                  {
                                                    "r": "134",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "singleton from "
                                                        ]
                                                      },
                                                      {
                                                        "r": "133",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "( "
                                                            ]
                                                          },
                                                          {
                                                            "r": "133",
                                                            "s": [
                                                              {
                                                                "s": [
                                                                  {
                                                                    "r": "125",
                                                                    "s": [
                                                                      {
                                                                        "r": "124",
                                                                        "s": [
                                                                          {
                                                                            "r": "124",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "[",
                                                                                  "\"Encounter, Performed\"",
                                                                                  ": "
                                                                                ]
                                                                              },
                                                                              {
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "\"Emergency Department Visit\""
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "]"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " ",
                                                                          "EDVisit"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "\n\t\t\t"
                                                                ]
                                                              },
                                                              {
                                                                "r": "132",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "where "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "132",
                                                                    "s": [
                                                                      {
                                                                        "r": "127",
                                                                        "s": [
                                                                          {
                                                                            "r": "126",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "EDVisit"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              "."
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "127",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "relevantPeriod"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "132",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "ends "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "131",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "1 ",
                                                                                  "hour"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              " or less on or before"
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "130",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "start of "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "129",
                                                                            "s": [
                                                                              {
                                                                                "r": "128",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "Encounter"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "."
                                                                                ]
                                                                              },
                                                                              {
                                                                                "r": "129",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "relevantPeriod"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "\n\t)"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      " )"
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " ",
                                                  "EDEncounter"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          "\n\t\t"
                                        ]
                                      },
                                      {
                                        "r": "147",
                                        "s": [
                                          {
                                            "value": [
                                              "return "
                                            ]
                                          },
                                          {
                                            "r": "146",
                                            "s": [
                                              {
                                                "value": [
                                                  "if "
                                                ]
                                              },
                                              {
                                                "r": "137",
                                                "s": [
                                                  {
                                                    "r": "136",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "EDEncounter"
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      " is null"
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " then "
                                                ]
                                              },
                                              {
                                                "r": "139",
                                                "s": [
                                                  {
                                                    "r": "138",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "Encounter"
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "."
                                                    ]
                                                  },
                                                  {
                                                    "r": "139",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "facilityLocations"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  " else "
                                                ]
                                              },
                                              {
                                                "r": "145",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "flatten "
                                                    ]
                                                  },
                                                  {
                                                    "r": "144",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "{ "
                                                        ]
                                                      },
                                                      {
                                                        "r": "141",
                                                        "s": [
                                                          {
                                                            "r": "140",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "EDEncounter"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "141",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "facilityLocations"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          ", "
                                                        ]
                                                      },
                                                      {
                                                        "r": "143",
                                                        "s": [
                                                          {
                                                            "r": "142",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "Encounter"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "143",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "facilityLocations"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " }"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "148",
                        "locator": "68:2-71:140",
                        "type": "Query",
                        "source": [
                          {
                            "localId": "135",
                            "locator": "68:2-70:16",
                            "alias": "EDEncounter",
                            "expression": {
                              "localId": "134",
                              "locator": "68:2-70:4",
                              "type": "SingletonFrom",
                              "operand": {
                                "localId": "133",
                                "locator": "68:19-70:2",
                                "type": "Query",
                                "source": [
                                  {
                                    "localId": "125",
                                    "locator": "68:21-68:82",
                                    "alias": "EDVisit",
                                    "expression": {
                                      "localId": "124",
                                      "locator": "68:21-68:74",
                                      "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                      "templateId": "PositiveEncounterPerformed",
                                      "codeProperty": "code",
                                      "type": "Retrieve",
                                      "codes": {
                                        "name": "Emergency Department Visit",
                                        "type": "ValueSetRef"
                                      }
                                    }
                                  }
                                ],
                                "relationship": [
        
                                ],
                                "where": {
                                  "localId": "132",
                                  "locator": "69:4-69:98",
                                  "type": "In",
                                  "operand": [
                                    {
                                      "locator": "69:33-69:36",
                                      "type": "End",
                                      "operand": {
                                        "localId": "127",
                                        "locator": "69:10-69:31",
                                        "path": "relevantPeriod",
                                        "scope": "EDVisit",
                                        "type": "Property"
                                      }
                                    },
                                    {
                                      "locator": "69:38-69:51",
                                      "lowClosed": true,
                                      "highClosed": true,
                                      "type": "Interval",
                                      "low": {
                                        "locator": "69:66-69:98",
                                        "type": "Subtract",
                                        "operand": [
                                          {
                                            "localId": "130",
                                            "locator": "69:66-69:98",
                                            "type": "Start",
                                            "operand": {
                                              "localId": "129",
                                              "locator": "69:75-69:98",
                                              "path": "relevantPeriod",
                                              "type": "Property",
                                              "source": {
                                                "localId": "128",
                                                "locator": "69:75-69:83",
                                                "name": "Encounter",
                                                "type": "OperandRef"
                                              }
                                            }
                                          },
                                          {
                                            "localId": "131",
                                            "locator": "69:38-69:43",
                                            "value": 1,
                                            "unit": "hour",
                                            "type": "Quantity"
                                          }
                                        ]
                                      },
                                      "high": {
                                        "localId": "130",
                                        "locator": "69:66-69:98",
                                        "type": "Start",
                                        "operand": {
                                          "localId": "129",
                                          "locator": "69:75-69:98",
                                          "path": "relevantPeriod",
                                          "type": "Property",
                                          "source": {
                                            "localId": "128",
                                            "locator": "69:75-69:83",
                                            "name": "Encounter",
                                            "type": "OperandRef"
                                          }
                                        }
                                      }
                                    }
                                  ]
                                }
                              }
                            }
                          }
                        ],
                        "relationship": [
        
                        ],
                        "return": {
                          "localId": "147",
                          "locator": "71:3-71:140",
                          "expression": {
                            "localId": "146",
                            "locator": "71:10-71:140",
                            "type": "If",
                            "condition": {
                              "asType": "{urn:hl7-org:elm-types:r1}Boolean",
                              "type": "As",
                              "operand": {
                                "localId": "137",
                                "locator": "71:13-71:31",
                                "type": "IsNull",
                                "operand": {
                                  "localId": "136",
                                  "locator": "71:13-71:23",
                                  "name": "EDEncounter",
                                  "type": "AliasRef"
                                }
                              },
                              "asTypeSpecifier": {
                                "name": "{urn:hl7-org:elm-types:r1}Boolean",
                                "type": "NamedTypeSpecifier"
                              }
                            },
                            "then": {
                              "localId": "139",
                              "locator": "71:38-71:64",
                              "path": "facilityLocations",
                              "type": "Property",
                              "source": {
                                "localId": "138",
                                "locator": "71:38-71:46",
                                "name": "Encounter",
                                "type": "OperandRef"
                              }
                            },
                            "else": {
                              "localId": "145",
                              "locator": "71:71-71:140",
                              "type": "Flatten",
                              "operand": {
                                "localId": "144",
                                "locator": "71:79-71:140",
                                "type": "List",
                                "element": [
                                  {
                                    "localId": "141",
                                    "locator": "71:81-71:109",
                                    "path": "facilityLocations",
                                    "scope": "EDEncounter",
                                    "type": "Property"
                                  },
                                  {
                                    "localId": "143",
                                    "locator": "71:112-71:138",
                                    "path": "facilityLocations",
                                    "type": "Property",
                                    "source": {
                                      "localId": "142",
                                      "locator": "71:112-71:120",
                                      "name": "Encounter",
                                      "type": "OperandRef"
                                    }
                                  }
                                ]
                              }
                            }
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "123",
                            "locator": "67:55-67:76",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "154",
                      "locator": "74:1-75:43",
                      "name": "Hospitalization Length of Stay",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "154",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Hospitalization Length of Stay\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "150",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "153",
                                "s": [
                                  {
                                    "r": "153",
                                    "s": [
                                      {
                                        "value": [
                                          "LengthInDays",
                                          "("
                                        ]
                                      },
                                      {
                                        "r": "152",
                                        "s": [
                                          {
                                            "value": [
                                              "\"Hospitalization\"",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "151",
                                            "s": [
                                              {
                                                "value": [
                                                  "Encounter"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          ")"
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "153",
                        "locator": "75:2-75:43",
                        "name": "LengthInDays",
                        "type": "FunctionRef",
                        "operand": [
                          {
                            "localId": "152",
                            "locator": "75:15-75:42",
                            "name": "Hospitalization",
                            "type": "FunctionRef",
                            "operand": [
                              {
                                "localId": "151",
                                "locator": "75:33-75:41",
                                "name": "Encounter",
                                "type": "OperandRef"
                              }
                            ]
                          }
                        ]
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "150",
                            "locator": "74:60-74:81",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "159",
                      "locator": "79:1-80:38",
                      "name": "Hospital Admission Time",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "159",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Hospital Admission Time\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "155",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "158",
                                "s": [
                                  {
                                    "r": "158",
                                    "s": [
                                      {
                                        "value": [
                                          "start of "
                                        ]
                                      },
                                      {
                                        "r": "157",
                                        "s": [
                                          {
                                            "value": [
                                              "\"Hospitalization\"",
                                              "("
                                            ]
                                          },
                                          {
                                            "r": "156",
                                            "s": [
                                              {
                                                "value": [
                                                  "Encounter"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              ")"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "158",
                        "locator": "80:2-80:38",
                        "type": "Start",
                        "operand": {
                          "localId": "157",
                          "locator": "80:11-80:38",
                          "name": "Hospitalization",
                          "type": "FunctionRef",
                          "operand": [
                            {
                              "localId": "156",
                              "locator": "80:29-80:37",
                              "name": "Encounter",
                              "type": "OperandRef"
                            }
                          ]
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "155",
                            "locator": "79:53-79:74",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "164",
                      "locator": "83:1-84:32",
                      "name": "Hospital Discharge Time",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "164",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Hospital Discharge Time\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "160",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "163",
                                "s": [
                                  {
                                    "r": "163",
                                    "s": [
                                      {
                                        "value": [
                                          "end of "
                                        ]
                                      },
                                      {
                                        "r": "162",
                                        "s": [
                                          {
                                            "r": "161",
                                            "s": [
                                              {
                                                "value": [
                                                  "Encounter"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "."
                                            ]
                                          },
                                          {
                                            "r": "162",
                                            "s": [
                                              {
                                                "value": [
                                                  "relevantPeriod"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "163",
                        "locator": "84:2-84:32",
                        "type": "End",
                        "operand": {
                          "localId": "162",
                          "locator": "84:9-84:32",
                          "path": "relevantPeriod",
                          "type": "Property",
                          "source": {
                            "localId": "161",
                            "locator": "84:9-84:17",
                            "name": "Encounter",
                            "type": "OperandRef"
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "160",
                            "locator": "83:53-83:74",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "177",
                      "locator": "88:1-91:17",
                      "name": "Hospital Arrival Time",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "177",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Hospital Arrival Time\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "165",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "176",
                                "s": [
                                  {
                                    "r": "176",
                                    "s": [
                                      {
                                        "value": [
                                          "start of "
                                        ]
                                      },
                                      {
                                        "r": "175",
                                        "s": [
                                          {
                                            "r": "174",
                                            "s": [
                                              {
                                                "value": [
                                                  "First",
                                                  "("
                                                ]
                                              },
                                              {
                                                "r": "173",
                                                "s": [
                                                  {
                                                    "s": [
                                                      {
                                                        "r": "168",
                                                        "s": [
                                                          {
                                                            "r": "167",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "("
                                                                ]
                                                              },
                                                              {
                                                                "r": "167",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "\"Hospitalization Locations\"",
                                                                      "("
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "166",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "Encounter"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      ")"
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  ")"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "HospitalLocation"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "\n\t\t\t"
                                                    ]
                                                  },
                                                  {
                                                    "r": "172",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "sort by "
                                                        ]
                                                      },
                                                      {
                                                        "r": "171",
                                                        "s": [
                                                          {
                                                            "r": "170",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "start of "
                                                                ]
                                                              },
                                                              {
                                                                "r": "169",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "locationPeriod"
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t)"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "."
                                            ]
                                          },
                                          {
                                            "r": "175",
                                            "s": [
                                              {
                                                "value": [
                                                  "locationPeriod"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "176",
                        "locator": "89:2-91:17",
                        "type": "Start",
                        "operand": {
                          "localId": "175",
                          "locator": "89:11-91:17",
                          "path": "locationPeriod",
                          "type": "Property",
                          "source": {
                            "localId": "174",
                            "locator": "89:11-91:2",
                            "type": "First",
                            "source": {
                              "localId": "173",
                              "locator": "89:17-90:34",
                              "type": "Query",
                              "source": [
                                {
                                  "localId": "168",
                                  "locator": "89:17-89:72",
                                  "alias": "HospitalLocation",
                                  "expression": {
                                    "localId": "167",
                                    "locator": "89:17-89:56",
                                    "name": "Hospitalization Locations",
                                    "type": "FunctionRef",
                                    "operand": [
                                      {
                                        "localId": "166",
                                        "locator": "89:46-89:54",
                                        "name": "Encounter",
                                        "type": "OperandRef"
                                      }
                                    ]
                                  }
                                }
                              ],
                              "relationship": [
        
                              ],
                              "sort": {
                                "localId": "172",
                                "locator": "90:4-90:34",
                                "by": [
                                  {
                                    "localId": "171",
                                    "locator": "90:12-90:34",
                                    "direction": "asc",
                                    "type": "ByExpression",
                                    "expression": {
                                      "localId": "170",
                                      "locator": "90:12-90:34",
                                      "type": "Start",
                                      "operand": {
                                        "localId": "169",
                                        "locator": "90:21-90:34",
                                        "name": "locationPeriod",
                                        "type": "IdentifierRef"
                                      }
                                    }
                                  }
                                ]
                              }
                            }
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "165",
                            "locator": "88:51-88:72",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "190",
                      "locator": "94:1-97:17",
                      "name": "Hospital Departure Time",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "190",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Hospital Departure Time\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "178",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "189",
                                "s": [
                                  {
                                    "r": "189",
                                    "s": [
                                      {
                                        "value": [
                                          "end of "
                                        ]
                                      },
                                      {
                                        "r": "188",
                                        "s": [
                                          {
                                            "r": "187",
                                            "s": [
                                              {
                                                "value": [
                                                  "Last",
                                                  "("
                                                ]
                                              },
                                              {
                                                "r": "186",
                                                "s": [
                                                  {
                                                    "s": [
                                                      {
                                                        "r": "181",
                                                        "s": [
                                                          {
                                                            "r": "180",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "("
                                                                ]
                                                              },
                                                              {
                                                                "r": "180",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "\"Hospitalization Locations\"",
                                                                      "("
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "179",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "Encounter"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      ")"
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  ")"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "HospitalLocation"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "\n\t\t\t"
                                                    ]
                                                  },
                                                  {
                                                    "r": "185",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "sort by "
                                                        ]
                                                      },
                                                      {
                                                        "r": "184",
                                                        "s": [
                                                          {
                                                            "r": "183",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "start of "
                                                                ]
                                                              },
                                                              {
                                                                "r": "182",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "locationPeriod"
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t)"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "."
                                            ]
                                          },
                                          {
                                            "r": "188",
                                            "s": [
                                              {
                                                "value": [
                                                  "locationPeriod"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "189",
                        "locator": "95:2-97:17",
                        "type": "End",
                        "operand": {
                          "localId": "188",
                          "locator": "95:9-97:17",
                          "path": "locationPeriod",
                          "type": "Property",
                          "source": {
                            "localId": "187",
                            "locator": "95:9-97:2",
                            "type": "Last",
                            "source": {
                              "localId": "186",
                              "locator": "95:14-96:34",
                              "type": "Query",
                              "source": [
                                {
                                  "localId": "181",
                                  "locator": "95:14-95:69",
                                  "alias": "HospitalLocation",
                                  "expression": {
                                    "localId": "180",
                                    "locator": "95:14-95:53",
                                    "name": "Hospitalization Locations",
                                    "type": "FunctionRef",
                                    "operand": [
                                      {
                                        "localId": "179",
                                        "locator": "95:43-95:51",
                                        "name": "Encounter",
                                        "type": "OperandRef"
                                      }
                                    ]
                                  }
                                }
                              ],
                              "relationship": [
        
                              ],
                              "sort": {
                                "localId": "185",
                                "locator": "96:4-96:34",
                                "by": [
                                  {
                                    "localId": "184",
                                    "locator": "96:12-96:34",
                                    "direction": "asc",
                                    "type": "ByExpression",
                                    "expression": {
                                      "localId": "183",
                                      "locator": "96:12-96:34",
                                      "type": "Start",
                                      "operand": {
                                        "localId": "182",
                                        "locator": "96:21-96:34",
                                        "name": "locationPeriod",
                                        "type": "IdentifierRef"
                                      }
                                    }
                                  }
                                ]
                              }
                            }
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "178",
                            "locator": "94:53-94:74",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "203",
                      "locator": "101:1-105:17",
                      "name": "Emergency Department Arrival Time",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "203",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"Emergency Department Arrival Time\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "191",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "202",
                                "s": [
                                  {
                                    "r": "202",
                                    "s": [
                                      {
                                        "value": [
                                          "start of "
                                        ]
                                      },
                                      {
                                        "r": "201",
                                        "s": [
                                          {
                                            "r": "200",
                                            "s": [
                                              {
                                                "value": [
                                                  "( "
                                                ]
                                              },
                                              {
                                                "r": "200",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "singleton from "
                                                    ]
                                                  },
                                                  {
                                                    "r": "199",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "( "
                                                        ]
                                                      },
                                                      {
                                                        "r": "199",
                                                        "s": [
                                                          {
                                                            "s": [
                                                              {
                                                                "r": "194",
                                                                "s": [
                                                                  {
                                                                    "r": "193",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "( "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "193",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "\"Hospitalization Locations\"",
                                                                              "("
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "192",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "Encounter"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              ")"
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          ")"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      " ",
                                                                      "HospitalLocation"
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "\n\t\t\t\t"
                                                            ]
                                                          },
                                                          {
                                                            "r": "198",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "where "
                                                                ]
                                                              },
                                                              {
                                                                "r": "198",
                                                                "s": [
                                                                  {
                                                                    "r": "196",
                                                                    "s": [
                                                                      {
                                                                        "r": "195",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "HospitalLocation"
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          "."
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "196",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "code"
                                                                            ]
                                                                          }
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      " in "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "197",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "\"Emergency Department Visit\""
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          "\n\t\t)"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t)"
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "."
                                            ]
                                          },
                                          {
                                            "r": "201",
                                            "s": [
                                              {
                                                "value": [
                                                  "locationPeriod"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "202",
                        "locator": "102:2-105:17",
                        "type": "Start",
                        "operand": {
                          "localId": "201",
                          "locator": "102:11-105:17",
                          "path": "locationPeriod",
                          "type": "Property",
                          "source": {
                            "localId": "200",
                            "locator": "102:11-105:2",
                            "type": "SingletonFrom",
                            "operand": {
                              "localId": "199",
                              "locator": "102:28-104:3",
                              "type": "Query",
                              "source": [
                                {
                                  "localId": "194",
                                  "locator": "102:30-102:87",
                                  "alias": "HospitalLocation",
                                  "expression": {
                                    "localId": "193",
                                    "locator": "102:30-102:70",
                                    "name": "Hospitalization Locations",
                                    "type": "FunctionRef",
                                    "operand": [
                                      {
                                        "localId": "192",
                                        "locator": "102:60-102:68",
                                        "name": "Encounter",
                                        "type": "OperandRef"
                                      }
                                    ]
                                  }
                                }
                              ],
                              "relationship": [
        
                              ],
                              "where": {
                                "localId": "198",
                                "locator": "103:5-103:63",
                                "type": "InValueSet",
                                "code": {
                                  "localId": "196",
                                  "locator": "103:11-103:31",
                                  "path": "code",
                                  "scope": "HospitalLocation",
                                  "type": "Property"
                                },
                                "valueset": {
                                  "localId": "197",
                                  "locator": "103:36-103:63",
                                  "name": "Emergency Department Visit"
                                }
                              }
                            }
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "191",
                            "locator": "101:63-101:84",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    },
                    {
                      "localId": "224",
                      "locator": "110:1-115:2",
                      "name": "First Inpatient Intensive Care Unit",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "type": "FunctionDef",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "224",
                            "s": [
                              {
                                "value": [
                                  "define function ",
                                  "\"First Inpatient Intensive Care Unit\"",
                                  "(",
                                  "Encounter",
                                  " "
                                ]
                              },
                              {
                                "r": "204",
                                "s": [
                                  {
                                    "value": [
                                      "\"Encounter, Performed\""
                                    ]
                                  }
                                ]
                              },
                              {
                                "value": [
                                  " ):\n\t"
                                ]
                              },
                              {
                                "r": "223",
                                "s": [
                                  {
                                    "r": "223",
                                    "s": [
                                      {
                                        "value": [
                                          "First",
                                          "("
                                        ]
                                      },
                                      {
                                        "r": "222",
                                        "s": [
                                          {
                                            "s": [
                                              {
                                                "r": "207",
                                                "s": [
                                                  {
                                                    "r": "206",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "("
                                                        ]
                                                      },
                                                      {
                                                        "r": "206",
                                                        "s": [
                                                          {
                                                            "r": "205",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "Encounter"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "206",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "facilityLocations"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          ")"
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "HospitalLocation"
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "\n\t\t\t"
                                            ]
                                          },
                                          {
                                            "r": "217",
                                            "s": [
                                              {
                                                "value": [
                                                  "where "
                                                ]
                                              },
                                              {
                                                "r": "217",
                                                "s": [
                                                  {
                                                    "r": "211",
                                                    "s": [
                                                      {
                                                        "r": "209",
                                                        "s": [
                                                          {
                                                            "r": "208",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "HospitalLocation"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "209",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "code"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " in "
                                                        ]
                                                      },
                                                      {
                                                        "r": "210",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "\"Intensive Care Unit\""
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "\n\t\t\t\tand "
                                                    ]
                                                  },
                                                  {
                                                    "r": "216",
                                                    "s": [
                                                      {
                                                        "r": "213",
                                                        "s": [
                                                          {
                                                            "r": "212",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "HospitalLocation"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "213",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "locationPeriod"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "during",
                                                          " "
                                                        ]
                                                      },
                                                      {
                                                        "r": "215",
                                                        "s": [
                                                          {
                                                            "r": "214",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "Encounter"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "215",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "relevantPeriod"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "\n\t\t\t"
                                            ]
                                          },
                                          {
                                            "r": "221",
                                            "s": [
                                              {
                                                "value": [
                                                  "sort by "
                                                ]
                                              },
                                              {
                                                "r": "220",
                                                "s": [
                                                  {
                                                    "r": "219",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "start of "
                                                        ]
                                                      },
                                                      {
                                                        "r": "218",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "locationPeriod"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          "\n\t)"
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "223",
                        "locator": "111:2-115:2",
                        "type": "First",
                        "source": {
                          "localId": "222",
                          "locator": "111:8-114:34",
                          "type": "Query",
                          "source": [
                            {
                              "localId": "207",
                              "locator": "111:8-111:52",
                              "alias": "HospitalLocation",
                              "expression": {
                                "localId": "206",
                                "locator": "111:8-111:36",
                                "path": "facilityLocations",
                                "type": "Property",
                                "source": {
                                  "localId": "205",
                                  "locator": "111:9-111:17",
                                  "name": "Encounter",
                                  "type": "OperandRef"
                                }
                              }
                            }
                          ],
                          "relationship": [
        
                          ],
                          "where": {
                            "localId": "217",
                            "locator": "112:4-113:71",
                            "type": "And",
                            "operand": [
                              {
                                "localId": "211",
                                "locator": "112:10-112:55",
                                "type": "InValueSet",
                                "code": {
                                  "localId": "209",
                                  "locator": "112:10-112:30",
                                  "path": "code",
                                  "scope": "HospitalLocation",
                                  "type": "Property"
                                },
                                "valueset": {
                                  "localId": "210",
                                  "locator": "112:35-112:55",
                                  "name": "Intensive Care Unit"
                                }
                              },
                              {
                                "localId": "216",
                                "locator": "113:9-113:71",
                                "type": "IncludedIn",
                                "operand": [
                                  {
                                    "localId": "213",
                                    "locator": "113:9-113:39",
                                    "path": "locationPeriod",
                                    "scope": "HospitalLocation",
                                    "type": "Property"
                                  },
                                  {
                                    "localId": "215",
                                    "locator": "113:48-113:71",
                                    "path": "relevantPeriod",
                                    "type": "Property",
                                    "source": {
                                      "localId": "214",
                                      "locator": "113:48-113:56",
                                      "name": "Encounter",
                                      "type": "OperandRef"
                                    }
                                  }
                                ]
                              }
                            ]
                          },
                          "sort": {
                            "localId": "221",
                            "locator": "114:4-114:34",
                            "by": [
                              {
                                "localId": "220",
                                "locator": "114:12-114:34",
                                "direction": "asc",
                                "type": "ByExpression",
                                "expression": {
                                  "localId": "219",
                                  "locator": "114:12-114:34",
                                  "type": "Start",
                                  "operand": {
                                    "localId": "218",
                                    "locator": "114:21-114:34",
                                    "name": "locationPeriod",
                                    "type": "IdentifierRef"
                                  }
                                }
                              }
                            ]
                          }
                        }
                      },
                      "operand": [
                        {
                          "name": "Encounter",
                          "operandTypeSpecifier": {
                            "localId": "204",
                            "locator": "110:65-110:86",
                            "name": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                            "type": "NamedTypeSpecifier"
                          }
                        }
                      ]
                    }
                  ]
                }
              }
            },
            {
              "library": {
                "identifier": {
                  "id": "Hospice",
                  "version": "1.0.000"
                },
                "schemaIdentifier": {
                  "id": "urn:hl7-org:elm",
                  "version": "r1"
                },
                "usings": {
                  "def": [
                    {
                      "localIdentifier": "System",
                      "uri": "urn:hl7-org:elm-types:r1"
                    },
                    {
                      "localId": "1",
                      "locator": "3:1-3:23",
                      "localIdentifier": "QDM",
                      "uri": "urn:healthit-gov:qdm:v5_3",
                      "version": "5.3"
                    }
                  ]
                },
                "parameters": {
                  "def": [
                    {
                      "localId": "18",
                      "locator": "18:1-18:49",
                      "name": "Measurement Period",
                      "accessLevel": "Public",
                      "parameterTypeSpecifier": {
                        "localId": "17",
                        "locator": "18:32-18:49",
                        "type": "IntervalTypeSpecifier",
                        "pointType": {
                          "localId": "16",
                          "locator": "18:41-18:48",
                          "name": "{urn:hl7-org:elm-types:r1}DateTime",
                          "type": "NamedTypeSpecifier"
                        }
                      }
                    }
                  ]
                },
                "codeSystems": {
                  "def": [
                    {
                      "localId": "2",
                      "locator": "5:1-5:87",
                      "name": "LOINC:2.46",
                      "id": "LOINC",
                      "version": "urn:hl7:version:2.46",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "3",
                      "locator": "6:1-6:97",
                      "name": "SNOMEDCT:2016-03",
                      "id": "SNOMED-CT",
                      "version": "urn:hl7:version:2016-03",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "4",
                      "locator": "7:1-7:97",
                      "name": "SNOMEDCT:2017-03",
                      "id": "SNOMED-CT",
                      "version": "urn:hl7:version:2017-03",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "5",
                      "locator": "8:1-8:97",
                      "name": "SNOMEDCT:2017-09",
                      "id": "SNOMED-CT",
                      "version": "urn:hl7:version:2017-09",
                      "accessLevel": "Public"
                    }
                  ]
                },
                "valueSets": {
                  "def": [
                    {
                      "localId": "6",
                      "locator": "10:1-10:71",
                      "name": "Encounter Inpatient",
                      "id": "2.16.840.1.113883.3.666.5.307",
                      "accessLevel": "Public"
                    },
                    {
                      "localId": "7",
                      "locator": "11:1-11:75",
                      "name": "Hospice care ambulatory",
                      "id": "2.16.840.1.113762.1.4.1108.15",
                      "accessLevel": "Public"
                    }
                  ]
                },
                "codes": {
                  "def": [
                    {
                      "localId": "9",
                      "locator": "13:1-13:66",
                      "name": "Birthdate",
                      "id": "21112-8",
                      "display": "Birth date",
                      "accessLevel": "Public",
                      "codeSystem": {
                        "localId": "8",
                        "locator": "13:34-13:45",
                        "name": "LOINC:2.46"
                      }
                    },
                    {
                      "localId": "11",
                      "locator": "14:1-14:63",
                      "name": "Dead",
                      "id": "419099009",
                      "display": "Dead",
                      "accessLevel": "Public",
                      "codeSystem": {
                        "localId": "10",
                        "locator": "14:31-14:48",
                        "name": "SNOMEDCT:2016-03"
                      }
                    },
                    {
                      "localId": "13",
                      "locator": "15:1-15:183",
                      "name": "Discharge to healthcare facility for hospice care (procedure)",
                      "id": "428371000124100",
                      "display": "Discharge to healthcare facility for hospice care (procedure)",
                      "accessLevel": "Public",
                      "codeSystem": {
                        "localId": "12",
                        "locator": "15:94-15:111",
                        "name": "SNOMEDCT:2017-09"
                      }
                    },
                    {
                      "localId": "15",
                      "locator": "16:1-16:153",
                      "name": "Discharge to home for hospice care (procedure)",
                      "id": "428361000124107",
                      "display": "Discharge to home for hospice care (procedure)",
                      "accessLevel": "Public",
                      "codeSystem": {
                        "localId": "14",
                        "locator": "16:79-16:96",
                        "name": "SNOMEDCT:2017-09"
                      }
                    }
                  ]
                },
                "statements": {
                  "def": [
                    {
                      "locator": "20:1-20:15",
                      "name": "Patient",
                      "context": "Patient",
                      "expression": {
                        "type": "SingletonFrom",
                        "operand": {
                          "locator": "20:1-20:15",
                          "dataType": "{urn:healthit-gov:qdm:v5_3}Patient",
                          "templateId": "Patient",
                          "type": "Retrieve"
                        }
                      }
                    },
                    {
                      "localId": "59",
                      "locator": "22:1-34:3",
                      "name": "Has Hospice",
                      "context": "Patient",
                      "accessLevel": "Public",
                      "annotation": [
                        {
                          "type": "Annotation",
                          "s": {
                            "r": "59",
                            "s": [
                              {
                                "value": [
                                  "define ",
                                  "\"Has Hospice\"",
                                  ":\n\t"
                                ]
                              },
                              {
                                "r": "58",
                                "s": [
                                  {
                                    "r": "49",
                                    "s": [
                                      {
                                        "r": "40",
                                        "s": [
                                          {
                                            "value": [
                                              "exists "
                                            ]
                                          },
                                          {
                                            "r": "39",
                                            "s": [
                                              {
                                                "value": [
                                                  "( "
                                                ]
                                              },
                                              {
                                                "r": "39",
                                                "s": [
                                                  {
                                                    "s": [
                                                      {
                                                        "r": "20",
                                                        "s": [
                                                          {
                                                            "r": "19",
                                                            "s": [
                                                              {
                                                                "r": "19",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "[",
                                                                      "\"Encounter, Performed\"",
                                                                      ": "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "\"Encounter Inpatient\""
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      "]"
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              " ",
                                                              "DischargeHospice"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "\n\t\t\t"
                                                    ]
                                                  },
                                                  {
                                                    "r": "38",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "where "
                                                        ]
                                                      },
                                                      {
                                                        "r": "38",
                                                        "s": [
                                                          {
                                                            "r": "33",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "( "
                                                                ]
                                                              },
                                                              {
                                                                "r": "33",
                                                                "s": [
                                                                  {
                                                                    "r": "26",
                                                                    "s": [
                                                                      {
                                                                        "r": "24",
                                                                        "s": [
                                                                          {
                                                                            "r": "22",
                                                                            "s": [
                                                                              {
                                                                                "r": "21",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "DischargeHospice"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "."
                                                                                ]
                                                                              },
                                                                              {
                                                                                "r": "22",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "dischargeDisposition"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              " as "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "23",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "Code"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " ",
                                                                          "~",
                                                                          " "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "25",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "\"Discharge to home for hospice care (procedure)\""
                                                                            ]
                                                                          }
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      "\n\t\t\t\t\tor "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "32",
                                                                    "s": [
                                                                      {
                                                                        "r": "30",
                                                                        "s": [
                                                                          {
                                                                            "r": "28",
                                                                            "s": [
                                                                              {
                                                                                "r": "27",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "DischargeHospice"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              },
                                                                              {
                                                                                "value": [
                                                                                  "."
                                                                                ]
                                                                              },
                                                                              {
                                                                                "r": "28",
                                                                                "s": [
                                                                                  {
                                                                                    "value": [
                                                                                      "dischargeDisposition"
                                                                                    ]
                                                                                  }
                                                                                ]
                                                                              }
                                                                            ]
                                                                          },
                                                                          {
                                                                            "value": [
                                                                              " as "
                                                                            ]
                                                                          },
                                                                          {
                                                                            "r": "29",
                                                                            "s": [
                                                                              {
                                                                                "value": [
                                                                                  "Code"
                                                                                ]
                                                                              }
                                                                            ]
                                                                          }
                                                                        ]
                                                                      },
                                                                      {
                                                                        "value": [
                                                                          " ",
                                                                          "~",
                                                                          " "
                                                                        ]
                                                                      },
                                                                      {
                                                                        "r": "31",
                                                                        "s": [
                                                                          {
                                                                            "value": [
                                                                              "\"Discharge to healthcare facility for hospice care (procedure)\""
                                                                            ]
                                                                          }
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "\n\t\t\t)"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "\n\t\t\t\tand "
                                                            ]
                                                          },
                                                          {
                                                            "r": "37",
                                                            "s": [
                                                              {
                                                                "r": "35",
                                                                "s": [
                                                                  {
                                                                    "r": "34",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "DischargeHospice"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      "."
                                                                    ]
                                                                  },
                                                                  {
                                                                    "r": "35",
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "relevantPeriod"
                                                                        ]
                                                                      }
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  " ",
                                                                  "ends during",
                                                                  " "
                                                                ]
                                                              },
                                                              {
                                                                "r": "36",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "\"Measurement Period\""
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t)"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "value": [
                                          "\n\t\tor "
                                        ]
                                      },
                                      {
                                        "r": "48",
                                        "s": [
                                          {
                                            "value": [
                                              "exists "
                                            ]
                                          },
                                          {
                                            "r": "47",
                                            "s": [
                                              {
                                                "value": [
                                                  "( "
                                                ]
                                              },
                                              {
                                                "r": "47",
                                                "s": [
                                                  {
                                                    "s": [
                                                      {
                                                        "r": "42",
                                                        "s": [
                                                          {
                                                            "r": "41",
                                                            "s": [
                                                              {
                                                                "r": "41",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "[",
                                                                      "\"Intervention, Order\"",
                                                                      ": "
                                                                    ]
                                                                  },
                                                                  {
                                                                    "s": [
                                                                      {
                                                                        "value": [
                                                                          "\"Hospice care ambulatory\""
                                                                        ]
                                                                      }
                                                                    ]
                                                                  },
                                                                  {
                                                                    "value": [
                                                                      "]"
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              " ",
                                                              "HospiceOrder"
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  },
                                                  {
                                                    "value": [
                                                      "\n\t\t\t\t"
                                                    ]
                                                  },
                                                  {
                                                    "r": "46",
                                                    "s": [
                                                      {
                                                        "value": [
                                                          "where "
                                                        ]
                                                      },
                                                      {
                                                        "r": "46",
                                                        "s": [
                                                          {
                                                            "r": "44",
                                                            "s": [
                                                              {
                                                                "r": "43",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "HospiceOrder"
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "."
                                                                ]
                                                              },
                                                              {
                                                                "r": "44",
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "authorDatetime"
                                                                    ]
                                                                  }
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              " ",
                                                              "during",
                                                              " "
                                                            ]
                                                          },
                                                          {
                                                            "r": "45",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "\"Measurement Period\""
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t\t)"
                                                ]
                                              }
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  },
                                  {
                                    "value": [
                                      "\n\t\tor "
                                    ]
                                  },
                                  {
                                    "r": "57",
                                    "s": [
                                      {
                                        "value": [
                                          "exists "
                                        ]
                                      },
                                      {
                                        "r": "56",
                                        "s": [
                                          {
                                            "value": [
                                              "( "
                                            ]
                                          },
                                          {
                                            "r": "56",
                                            "s": [
                                              {
                                                "s": [
                                                  {
                                                    "r": "51",
                                                    "s": [
                                                      {
                                                        "r": "50",
                                                        "s": [
                                                          {
                                                            "r": "50",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "[",
                                                                  "\"Intervention, Performed\"",
                                                                  ": "
                                                                ]
                                                              },
                                                              {
                                                                "s": [
                                                                  {
                                                                    "value": [
                                                                      "\"Hospice care ambulatory\""
                                                                    ]
                                                                  }
                                                                ]
                                                              },
                                                              {
                                                                "value": [
                                                                  "]"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "HospicePerformed"
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              },
                                              {
                                                "value": [
                                                  "\n\t\t\t\t"
                                                ]
                                              },
                                              {
                                                "r": "55",
                                                "s": [
                                                  {
                                                    "value": [
                                                      "where "
                                                    ]
                                                  },
                                                  {
                                                    "r": "55",
                                                    "s": [
                                                      {
                                                        "r": "53",
                                                        "s": [
                                                          {
                                                            "r": "52",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "HospicePerformed"
                                                                ]
                                                              }
                                                            ]
                                                          },
                                                          {
                                                            "value": [
                                                              "."
                                                            ]
                                                          },
                                                          {
                                                            "r": "53",
                                                            "s": [
                                                              {
                                                                "value": [
                                                                  "relevantPeriod"
                                                                ]
                                                              }
                                                            ]
                                                          }
                                                        ]
                                                      },
                                                      {
                                                        "value": [
                                                          " ",
                                                          "overlaps",
                                                          " "
                                                        ]
                                                      },
                                                      {
                                                        "r": "54",
                                                        "s": [
                                                          {
                                                            "value": [
                                                              "\"Measurement Period\""
                                                            ]
                                                          }
                                                        ]
                                                      }
                                                    ]
                                                  }
                                                ]
                                              }
                                            ]
                                          },
                                          {
                                            "value": [
                                              "\n\t\t)"
                                            ]
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                ]
                              }
                            ]
                          }
                        }
                      ],
                      "expression": {
                        "localId": "58",
                        "locator": "23:2-34:3",
                        "type": "Or",
                        "operand": [
                          {
                            "localId": "49",
                            "locator": "23:2-31:3",
                            "type": "Or",
                            "operand": [
                              {
                                "localId": "40",
                                "locator": "23:2-28:2",
                                "type": "Exists",
                                "operand": {
                                  "localId": "39",
                                  "locator": "23:9-28:2",
                                  "type": "Query",
                                  "source": [
                                    {
                                      "localId": "20",
                                      "locator": "23:11-23:74",
                                      "alias": "DischargeHospice",
                                      "expression": {
                                        "localId": "19",
                                        "locator": "23:11-23:57",
                                        "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveEncounterPerformed",
                                        "templateId": "PositiveEncounterPerformed",
                                        "codeProperty": "code",
                                        "type": "Retrieve",
                                        "codes": {
                                          "name": "Encounter Inpatient",
                                          "type": "ValueSetRef"
                                        }
                                      }
                                    }
                                  ],
                                  "relationship": [
        
                                  ],
                                  "where": {
                                    "localId": "38",
                                    "locator": "24:4-27:72",
                                    "type": "And",
                                    "operand": [
                                      {
                                        "localId": "33",
                                        "locator": "24:10-26:4",
                                        "type": "Or",
                                        "operand": [
                                          {
                                            "localId": "26",
                                            "locator": "24:12-24:107",
                                            "type": "Equivalent",
                                            "operand": [
                                              {
                                                "localId": "24",
                                                "locator": "24:12-24:56",
                                                "strict": false,
                                                "type": "As",
                                                "operand": {
                                                  "localId": "22",
                                                  "locator": "24:12-24:48",
                                                  "path": "dischargeDisposition",
                                                  "scope": "DischargeHospice",
                                                  "type": "Property"
                                                },
                                                "asTypeSpecifier": {
                                                  "localId": "23",
                                                  "locator": "24:53-24:56",
                                                  "name": "{urn:hl7-org:elm-types:r1}Code",
                                                  "type": "NamedTypeSpecifier"
                                                }
                                              },
                                              {
                                                "localId": "25",
                                                "locator": "24:60-24:107",
                                                "name": "Discharge to home for hospice care (procedure)",
                                                "type": "CodeRef"
                                              }
                                            ]
                                          },
                                          {
                                            "localId": "32",
                                            "locator": "25:9-25:119",
                                            "type": "Equivalent",
                                            "operand": [
                                              {
                                                "localId": "30",
                                                "locator": "25:9-25:53",
                                                "strict": false,
                                                "type": "As",
                                                "operand": {
                                                  "localId": "28",
                                                  "locator": "25:9-25:45",
                                                  "path": "dischargeDisposition",
                                                  "scope": "DischargeHospice",
                                                  "type": "Property"
                                                },
                                                "asTypeSpecifier": {
                                                  "localId": "29",
                                                  "locator": "25:50-25:53",
                                                  "name": "{urn:hl7-org:elm-types:r1}Code",
                                                  "type": "NamedTypeSpecifier"
                                                }
                                              },
                                              {
                                                "localId": "31",
                                                "locator": "25:57-25:119",
                                                "name": "Discharge to healthcare facility for hospice care (procedure)",
                                                "type": "CodeRef"
                                              }
                                            ]
                                          }
                                        ]
                                      },
                                      {
                                        "localId": "37",
                                        "locator": "27:9-27:72",
                                        "type": "In",
                                        "operand": [
                                          {
                                            "locator": "27:41-27:44",
                                            "type": "End",
                                            "operand": {
                                              "localId": "35",
                                              "locator": "27:9-27:39",
                                              "path": "relevantPeriod",
                                              "scope": "DischargeHospice",
                                              "type": "Property"
                                            }
                                          },
                                          {
                                            "localId": "36",
                                            "locator": "27:53-27:72",
                                            "name": "Measurement Period",
                                            "type": "ParameterRef"
                                          }
                                        ]
                                      }
                                    ]
                                  }
                                }
                              },
                              {
                                "localId": "48",
                                "locator": "29:6-31:3",
                                "type": "Exists",
                                "operand": {
                                  "localId": "47",
                                  "locator": "29:13-31:3",
                                  "type": "Query",
                                  "source": [
                                    {
                                      "localId": "42",
                                      "locator": "29:15-29:77",
                                      "alias": "HospiceOrder",
                                      "expression": {
                                        "localId": "41",
                                        "locator": "29:15-29:64",
                                        "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveInterventionOrder",
                                        "templateId": "PositiveInterventionOrder",
                                        "codeProperty": "code",
                                        "type": "Retrieve",
                                        "codes": {
                                          "name": "Hospice care ambulatory",
                                          "type": "ValueSetRef"
                                        }
                                      }
                                    }
                                  ],
                                  "relationship": [
        
                                  ],
                                  "where": {
                                    "localId": "46",
                                    "locator": "30:5-30:65",
                                    "type": "In",
                                    "operand": [
                                      {
                                        "localId": "44",
                                        "locator": "30:11-30:37",
                                        "path": "authorDatetime",
                                        "scope": "HospiceOrder",
                                        "type": "Property"
                                      },
                                      {
                                        "localId": "45",
                                        "locator": "30:46-30:65",
                                        "name": "Measurement Period",
                                        "type": "ParameterRef"
                                      }
                                    ]
                                  }
                                }
                              }
                            ]
                          },
                          {
                            "localId": "57",
                            "locator": "32:6-34:3",
                            "type": "Exists",
                            "operand": {
                              "localId": "56",
                              "locator": "32:13-34:3",
                              "type": "Query",
                              "source": [
                                {
                                  "localId": "51",
                                  "locator": "32:15-32:85",
                                  "alias": "HospicePerformed",
                                  "expression": {
                                    "localId": "50",
                                    "locator": "32:15-32:68",
                                    "dataType": "{urn:healthit-gov:qdm:v5_3}PositiveInterventionPerformed",
                                    "templateId": "PositiveInterventionPerformed",
                                    "codeProperty": "code",
                                    "type": "Retrieve",
                                    "codes": {
                                      "name": "Hospice care ambulatory",
                                      "type": "ValueSetRef"
                                    }
                                  }
                                }
                              ],
                              "relationship": [
        
                              ],
                              "where": {
                                "localId": "55",
                                "locator": "33:5-33:71",
                                "type": "Overlaps",
                                "operand": [
                                  {
                                    "localId": "53",
                                    "locator": "33:11-33:41",
                                    "path": "relevantPeriod",
                                    "scope": "HospicePerformed",
                                    "type": "Property"
                                  },
                                  {
                                    "localId": "54",
                                    "locator": "33:52-33:71",
                                    "name": "Measurement Period",
                                    "type": "ParameterRef"
                                  }
                                ]
                              }
                            }
                          }
                        ]
                      }
                    }
                  ]
                }
              }
            }
          ],
          "main_cql_library": "PneumococcalVaccinationStatusforOlderAdults",
          "cql_statement_dependencies": {
            "PneumococcalVaccinationStatusforOlderAdults": {
              "Patient": [
        
              ],
              "SDE Ethnicity": [
        
              ],
              "SDE Payer": [
        
              ],
              "SDE Race": [
        
              ],
              "SDE Sex": [
        
              ],
              "Qualifying Encounters": [
        
              ],
              "Initial Population": [
                {
                  "library_name": "MATGlobalCommonFunctions",
                  "statement_name": "CalendarAgeInYearsAt"
                },
                {
                  "library_name": "PneumococcalVaccinationStatusforOlderAdults",
                  "statement_name": "Qualifying Encounters"
                }
              ],
              "Denominator": [
                {
                  "library_name": "PneumococcalVaccinationStatusforOlderAdults",
                  "statement_name": "Initial Population"
                }
              ],
              "Numerator": [
        
              ],
              "Denominator Exclusions": [
                {
                  "library_name": "Hospice",
                  "statement_name": "Has Hospice"
                }
              ]
            },
            "MATGlobalCommonFunctions": {
              "CalendarAgeInYearsAt": [
                {
                  "library_name": "MATGlobalCommonFunctions",
                  "statement_name": "ToDate"
                }
              ],
              "ToDate": [
        
              ]
            },
            "Hospice": {
              "Has Hospice": [
        
              ]
            }
          },
          "populations_cql_map": {
            "IPP": [
              "Initial Population"
            ],
            "DENOM": [
              "Denominator"
            ],
            "DENEX": [
              "Denominator Exclusions"
            ],
            "NUMER": [
              "Numerator"
            ]
          },
          "value_set_oid_version_objects": [
            {
              "oid": "2.16.840.1.113762.1.4.1",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.114222.4.11.836",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.114222.4.11.837",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.114222.4.11.3591",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.526.3.1240",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.101.12.1016",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.101.12.1001",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.110.12.1027",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.110.12.1034",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.101.12.1025",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.101.12.1023",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.101.12.1014",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.101.12.1012",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.464.1003.101.11.1065",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.117.1.7.1.292",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113883.3.666.5.307",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113762.1.4.1110.23",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "2.16.840.1.113762.1.4.1108.15",
              "version": "Draft-59657B9B-01BF-4979-A090-8534DA1D0516"
            },
            {
              "oid": "drc-5e3dd7a2b908c12dc1dd525dd16ae9b969b86825d92d4b58d101ef476d44510b",
              "version": ""
            },
            {
              "oid": "drc-288b28533ea3e20c8bed70cf4e0a8d78afa536cf3be01339e67e189ef32d0b58",
              "version": ""
            },
            {
              "oid": "drc-2bbe231b80adbbda1f62e54d2e939c81babe4ae2c40bf6e55b22e5b6d44f4e02",
              "version": ""
            },
            {
              "oid": "drc-7e63a6e0afd51d085689e8824f313c508a0f9b1c39974cc93b34536627eed531",
              "version": ""
            }
          ],
          "oids": [
            "2.16.840.1.113762.1.4.1",
            "2.16.840.1.113762.1.4.1108.15",
            "2.16.840.1.113762.1.4.1110.23",
            "2.16.840.1.113883.3.117.1.7.1.292",
            "2.16.840.1.113883.3.464.1003.101.11.1065",
            "2.16.840.1.113883.3.464.1003.101.12.1001",
            "2.16.840.1.113883.3.464.1003.101.12.1012",
            "2.16.840.1.113883.3.464.1003.101.12.1014",
            "2.16.840.1.113883.3.464.1003.101.12.1016",
            "2.16.840.1.113883.3.464.1003.101.12.1023",
            "2.16.840.1.113883.3.464.1003.101.12.1025",
            "2.16.840.1.113883.3.464.1003.110.12.1027",
            "2.16.840.1.113883.3.464.1003.110.12.1034",
            "2.16.840.1.113883.3.526.3.1240",
            "2.16.840.1.113883.3.666.5.307",
            "2.16.840.1.114222.4.11.3591",
            "2.16.840.1.114222.4.11.836",
            "2.16.840.1.114222.4.11.837",
            "drc-288b28533ea3e20c8bed70cf4e0a8d78afa536cf3be01339e67e189ef32d0b58",
            "drc-2bbe231b80adbbda1f62e54d2e939c81babe4ae2c40bf6e55b22e5b6d44f4e02",
            "drc-5e3dd7a2b908c12dc1dd525dd16ae9b969b86825d92d4b58d101ef476d44510b",
            "drc-7e63a6e0afd51d085689e8824f313c508a0f9b1c39974cc93b34536627eed531"
          ],
          "population_ids": {
            "IPP": "AD7E66D5-D06C-4079-8086-8B2978CA1AEF",
            "DENOM": "FC166E13-A380-466E-8E38-2E86261ADB21",
            "DENEX": "A791271E-6A92-406C-B67B-C6F6175F3FE7",
            "NUMER": "BE0E99DE-0998-4E13-AEE7-8012513CF47E"
          },
          "bonnie_measure_id": "5af33666aeac503afbcde99f"
        }
        
    end
  end
end
