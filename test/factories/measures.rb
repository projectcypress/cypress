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
      category 'none'
      type 'ep'
      episode_of_care true
      sub_id 'a'
      hqmf_doc = {
        'id' => '0419',
        'hqmf_id' => 'BE65090C-EB1F-11E7-8C3F-9A214CF093AE',
        'hqmf_set_id' => 'C621C7B6-EB1F-11E7-8C3F-9A214CF093AE',
        'hqmf_version_number' => '6',
        'title' => 'Documentation of Current Medications in the Medical Record',
        'description' => "Percentage of visits for patients aged 18 years and older for which the eligible professional attests to documenting a list of current medications using all immediate resources available on the date of the encounter.  This list must include ALL known prescriptions, over-the-counters, herbals, and vitamin/mineral/dietary (nutritional) supplements AND must contain the medications' name, dosage, frequency and route of administration.",
        'cms_id' => 'CMS68v6',
        'populations' => [
          {
            'NUMER' => 'NUMER',
            'DENOM' => 'DENOM',
            'IPP' => 'IPP',
            'DENEX' => 'DENEX',
            'title' => 'BMI Recorded',
            'id' => 'Population1'
          },
          {
            'NUMER' => 'NUMER_1',
            'DENOM' => 'DENOM',
            'IPP' => 'IPP',
            'DENEX' => 'DENEX',
            'title' => 'Nutrition Counseling',
            'id' => 'Population2'
          },
          {
            'NUMER' => 'NUMER_2',
            'DENOM' => 'DENOM',
            'IPP' => 'IPP',
            'DENEX' => 'DENEX',
            'title' => 'Physical Activity Counseling',
            'id' => 'Population3'
          },
          {
            'IPP' => 'IPP_1',
            'DENOM' => 'DENOM',
            'NUMER' => 'NUMER',
            'DENEX' => 'DENEX',
            'stratification' => '95DF97E7-810D-48A5-8F02-99FA4B384A7B',
            'title' => 'BMI Recorded, RS1=> 3-11',
            'id' => 'Population4'
          },
          {
            'IPP' => 'IPP_2',
            'DENOM' => 'DENOM',
            'NUMER' => 'NUMER',
            'DENEX' => 'DENEX',
            'stratification' => '5722134D-5F7C-42AD-914B-E73B4C366D55',
            'title' => 'BMI Recorded, RS2=> 12-17',
            'id' => 'Population5'
          },
          {
            'IPP' => 'IPP_1',
            'DENOM' => 'DENOM',
            'NUMER' => 'NUMER_1',
            'DENEX' => 'DENEX',
            'stratification' => '95DF97E7-810D-48A5-8F02-99FA4B384A7B',
            'title' => 'Nutrition Counseling, RS1=> 3-11',
            'id' => 'Population6'
          },
          {
            'IPP' => 'IPP_2',
            'DENOM' => 'DENOM',
            'NUMER' => 'NUMER_1',
            'DENEX' => 'DENEX',
            'stratification' => '5722134D-5F7C-42AD-914B-E73B4C366D55',
            'title' => 'Nutrition Counseling, RS2=> 12-17',
            'id' => 'Population7'
          },
          {
            'IPP' => 'IPP_1',
            'DENOM' => 'DENOM',
            'NUMER' => 'NUMER_2',
            'DENEX' => 'DENEX',
            'stratification' => '95DF97E7-810D-48A5-8F02-99FA4B384A7B',
            'title' => 'Physical Activity Counseling, RS1=> 3-11',
            'id' => 'Population8'
          },
          {
            'IPP' => 'IPP_2',
            'DENOM' => 'DENOM',
            'NUMER' => 'NUMER_2',
            'DENEX' => 'DENEX',
            'stratification' => '5722134D-5F7C-42AD-914B-E73B4C366D55',
            'title' => 'Physical Activity Counseling, RS2=> 12-17',
            'id' => 'Population9'
          }
        ],
        'population_criteria' => {
          'DENEX' => {
            'conjunction?' => true,
            'type' => 'DENEX',
            'title' => 'Denominator',
            'hqmf_id' => '0163BB04-EB20-11E7-8C3F-9A214CF093AE',
            'preconditions' => [
              {
                'id' => 7,
                'preconditions' => [
                  {
                    'id' => 4,
                    'reference' => 'OccurrenceAPregnancy1_precondition_4'
                  },
                  {
                    'id' => 6,
                    'preconditions' => [
                      {
                        'id' => 2,
                        'reference' => 'OccurrenceAPregnancy1_precondition_2'
                      }
                    ],
                    'conjunction_code' => 'atLeastOneTrue',
                    'negation' => true
                  }
                ],
                'conjunction_code' => 'allTrue'
              }
            ]
          },
          'NUMER' => {
            'conjunction?' => true,
            'type' => 'NUMER',
            'title' => 'Numerator',
            'hqmf_id' => 'E60D324E-7606-42C2-8E46-5EE29289725D',
            'preconditions' => [
              {
                'id' => 16,
                'preconditions' => [
                  {
                    'id' => 14,
                    'preconditions' => [
                      {
                        'id' => 8,
                        'reference' => 'PhysicalExamFindingBmiPercentile_precondition_8'
                      },
                      {
                        'id' => 10,
                        'reference' => 'PhysicalExamFindingHeight_precondition_10'
                      },
                      {
                        'id' => 12,
                        'reference' => 'PhysicalExamFindingWeight_precondition_12'
                      }
                    ],
                    'conjunction_code' => 'allTrue'
                  }
                ],
                'conjunction_code' => 'allTrue'
              }
            ]
          },
          'NUMER_1' => {
            'conjunction?' => true,
            'type' => 'NUMER',
            'title' => 'Numerator',
            'hqmf_id' => 'E3ACA22F-9239-417D-8074-E4882FB0F848',
            'preconditions' => [
              {
                'id' => 19,
                'preconditions' => [
                  {
                    'id' => 17,
                    'reference' => 'InterventionPerformedCounselingForNutrition_precondition_17'
                  }
                ],
                'conjunction_code' => 'allTrue'
              }
            ]
          },
          'NUMER_2' => {
            'conjunction?' => true,
            'type' => 'NUMER',
            'title' => 'Numerator',
            'hqmf_id' => '84C557E8-41B1-43F6-8C1B-1D204335AAFB',
            'preconditions' => [
              {
                'id' => 22,
                'preconditions' => [
                  {
                    'id' => 20,
                    'reference' => 'InterventionPerformedCounselingForPhysicalActivity_precondition_20'
                  }
                ],
                'conjunction_code' => 'allTrue'
              }
            ]
          },
          'DENOM' => {
            'conjunction?' => true,
            'type' => 'DENOM',
            'title' => 'Denominator',
            'hqmf_id' => 'F7D7DC82-EB1F-11E7-8C3F-9A214CF093AE'
          },
          'IPP' => {
            'conjunction?' => true,
            'type' => 'IPP',
            'title' => 'Initial Patient Population',
            'hqmf_id' => 'F2666FD4-EB1F-11E7-8C3F-9A214CF093AE',
            'preconditions' => [
              {
                'id' => 43,
                'preconditions' => [
                  {
                    'id' => 23,
                    'reference' => 'PatientCharacteristicBirthdateBirthDate_precondition_23'
                  },
                  {
                    'id' => 25,
                    'reference' => 'PatientCharacteristicBirthdateBirthDate_precondition_25'
                  },
                  {
                    'id' => 41,
                    'preconditions' => [
                      {
                        'id' => 27,
                        'reference' => 'EncounterPerformedFaceToFaceInteraction_precondition_27'
                      },
                      {
                        'id' => 29,
                        'reference' => 'EncounterPerformedOfficeVisit_precondition_29'
                      },
                      {
                        'id' => 31,
                        'reference' => 'EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_31'
                      },
                      {
                        'id' => 33,
                        'reference' => 'EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_33'
                      },
                      {
                        'id' => 35,
                        'reference' => 'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_35'
                      },
                      {
                        'id' => 37,
                        'reference' => 'EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_37'
                      },
                      {
                        'id' => 39,
                        'reference' => 'EncounterPerformedHomeHealthcareServices_precondition_39'
                      }
                    ],
                    'conjunction_code' => 'atLeastOneTrue'
                  }
                ],
                'conjunction_code' => 'allTrue'
              }
            ]
          },
          'IPP_1' => {
            'conjunction?' => true,
            'type' => 'IPP',
            'title' => 'Initial Patient Population',
            'hqmf_id' => 'F2666FD4-EB1F-11E7-8C3F-9A214CF093AE',
            'preconditions' => [
              {
                'id' => 64,
                'preconditions' => [
                  {
                    'id' => 44,
                    'reference' => 'PatientCharacteristicBirthdateBirthDate_precondition_44'
                  },
                  {
                    'id' => 46,
                    'reference' => 'PatientCharacteristicBirthdateBirthDate_precondition_46'
                  },
                  {
                    'id' => 62,
                    'preconditions' => [
                      {
                        'id' => 48,
                        'reference' => 'EncounterPerformedFaceToFaceInteraction_precondition_48'
                      },
                      {
                        'id' => 50,
                        'reference' => 'EncounterPerformedOfficeVisit_precondition_50'
                      },
                      {
                        'id' => 52,
                        'reference' => 'EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_52'
                      },
                      {
                        'id' => 54,
                        'reference' => 'EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_54'
                      },
                      {
                        'id' => 56,
                        'reference' => 'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_56'
                      },
                      {
                        'id' => 58,
                        'reference' => 'EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_58'
                      },
                      {
                        'id' => 60,
                        'reference' => 'EncounterPerformedHomeHealthcareServices_precondition_60'
                      }
                    ],
                    'conjunction_code' => 'atLeastOneTrue'
                  }
                ],
                'conjunction_code' => 'allTrue'
              }
            ]
          },
          'IPP_2' => {
            'conjunction?' => true,
            'type' => 'IPP',
            'title' => 'Initial Patient Population',
            'hqmf_id' => 'F2666FD4-EB1F-11E7-8C3F-9A214CF093AE',
            'preconditions' => [
              {
                'id' => 85,
                'preconditions' => [
                  {
                    'id' => 65,
                    'reference' => 'PatientCharacteristicBirthdateBirthDate_precondition_65'
                  },
                  {
                    'id' => 67,
                    'reference' => 'PatientCharacteristicBirthdateBirthDate_precondition_67'
                  },
                  {
                    'id' => 83,
                    'preconditions' => [
                      {
                        'id' => 69,
                        'reference' => 'EncounterPerformedFaceToFaceInteraction_precondition_69'
                      },
                      {
                        'id' => 71,
                        'reference' => 'EncounterPerformedOfficeVisit_precondition_71'
                      },
                      {
                        'id' => 73,
                        'reference' => 'EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_73'
                      },
                      {
                        'id' => 75,
                        'reference' => 'EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_75'
                      },
                      {
                        'id' => 77,
                        'reference' => 'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_77'
                      },
                      {
                        'id' => 79,
                        'reference' => 'EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_79'
                      },
                      {
                        'id' => 81,
                        'reference' => 'EncounterPerformedHomeHealthcareServices_precondition_81'
                      }
                    ],
                    'conjunction_code' => 'atLeastOneTrue'
                  }
                ],
                'conjunction_code' => 'allTrue'
              }
            ]
          }
        },
        'data_criteria' => {
          'DiagnosisActivePregnancy' => {
            'title' => 'Pregnancy',
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
            'source_data_criteria' => 'DiagnosisActivePregnancy'
          },
          'PatientCharacteristicSexOncAdministrativeSex' => {
            'title' => 'ONC Administrative Sex',
            'description' => 'Patient Characteristic Sex=> ONC Administrative Sex',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '2.16.840.1.113762.1.4.1',
            'property' => 'gender',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_gender',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicSexOncAdministrativeSex',
            'value' => {
              'type' => 'CD',
              'system' => 'Administrative Sex',
              'code' => 'F'
            }
          },
          'PatientCharacteristicRaceRace' => {
            'title' => 'Race',
            'description' => 'Patient Characteristic Race=> Race',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '2.16.840.1.114222.4.11.836',
            'property' => 'race',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_race',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicRaceRace',
            'inline_code_list' => {
              'CDC Race' => [
                '1002-5',
                '2028-9',
                '2054-5',
                '2076-8',
                '2106-3',
                '2131-1'
              ]
            }
          },
          'PatientCharacteristicEthnicityEthnicity' => {
            'title' => 'Ethnicity',
            'description' => 'Patient Characteristic Ethnicity=> Ethnicity',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.1.2.3',
            'property' => 'ethnicity',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_ethnicity',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicEthnicityEthnicity',
            'inline_code_list' => {
              'CDC Race' => [
                '2135-2',
                '2186-5'
              ]
            }
          },
          'PatientCharacteristicPayerPayer' => {
            'title' => 'Payer',
            'description' => 'Patient Characteristic Payer=> Payer',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '2.16.840.1.114222.4.11.3591',
            'property' => 'payer',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_payer',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicPayerPayer',
            'inline_code_list' => {
              'Source of Payment Typology' => %w[1 2 349]
            }
          },
          'OccurrenceAPregnancy1_precondition_4' => {
            'title' => 'Pregnancy',
            'description' => 'Diagnosis, Active=> Pregnancy',
            'standard_category' => 'diagnosis_condition_problem',
            'qds_data_type' => 'diagnosis_active',
            'code_list_id' => '1.5.6.7',
            'type' => 'conditions',
            'definition' => 'diagnosis',
            'status' => 'active',
            'hard_status' => false,
            'negation' => false,
            'specific_occurrence' => 'A',
            'specific_occurrence_const' => 'DIAGNOSIS_ACTIVE_PREGNANCY',
            'source_data_criteria' => 'OccurrenceAPregnancy1',
            'temporal_references' => [
              {
                'type' => 'SBE',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'OccurrenceAPregnancy1_precondition_2' => {
            'title' => 'Pregnancy',
            'description' => 'Diagnosis, Active=> Pregnancy',
            'standard_category' => 'diagnosis_condition_problem',
            'qds_data_type' => 'diagnosis_active',
            'code_list_id' => '1.5.6.7',
            'type' => 'conditions',
            'definition' => 'diagnosis',
            'status' => 'active',
            'hard_status' => false,
            'negation' => false,
            'specific_occurrence' => 'A',
            'specific_occurrence_const' => 'DIAGNOSIS_ACTIVE_PREGNANCY',
            'source_data_criteria' => 'OccurrenceAPregnancy1',
            'temporal_references' => [
              {
                'type' => 'EBS',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'PhysicalExamFindingBmiPercentile_precondition_8' => {
            'title' => 'BMI percentile',
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
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'PhysicalExamFindingHeight_precondition_10' => {
            'title' => 'Height',
            'description' => 'Physical Exam, Finding=> Height',
            'standard_category' => 'physical_exam',
            'qds_data_type' => 'physical_exam',
            'code_list_id' => '1.8.9.10',
            'type' => 'physical_exams',
            'definition' => 'physical_exam',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PhysicalExamFindingHeight',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'PhysicalExamFindingWeight_precondition_12' => {
            'title' => 'Weight',
            'description' => 'Physical Exam, Finding=> Weight',
            'standard_category' => 'physical_exam',
            'qds_data_type' => 'physical_exam',
            'code_list_id' => '1.9.10.11',
            'type' => 'physical_exams',
            'definition' => 'physical_exam',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PhysicalExamFindingWeight',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'InterventionPerformedCounselingForNutrition_precondition_17' => {
            'title' => 'Counseling for Nutrition',
            'description' => 'Intervention, Performed=> Counseling for Nutrition',
            'standard_category' => 'procedure',
            'qds_data_type' => 'procedure_performed',
            'code_list_id' => '1.10.11.12',
            'type' => 'interventions',
            'definition' => 'intervention',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'InterventionPerformedCounselingForNutrition',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'InterventionPerformedCounselingForPhysicalActivity_precondition_20' => {
            'title' => 'Counseling for Physical Activity',
            'description' => 'Intervention, Performed=> Counseling for Physical Activity',
            'standard_category' => 'procedure',
            'qds_data_type' => 'procedure_performed',
            'code_list_id' => '1.11.12.13',
            'type' => 'interventions',
            'definition' => 'intervention',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'InterventionPerformedCounselingForPhysicalActivity',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'PatientCharacteristicBirthdateBirthDate_precondition_23' => {
            'title' => 'birth date',
            'description' => 'Patient Characteristic Birthdate=> birth date',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.2.3.4',
            'property' => 'birthtime',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_birthdate',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicBirthdateBirthDate',
            'inline_code_list' => {
              'LOINC' => [
                '21112-8'
              ]
            },
            'temporal_references' => [
              {
                'type' => 'SBS',
                'reference' => 'MeasurePeriod',
                'range' => {
                  'type' => 'IVL_PQ',
                  'low' => {
                    'type' => 'PQ',
                    'unit' => 'a',
                    'value' => '3',
                    'inclusive?' => true,
                    'derived?' => false
                  }
                }
              }
            ]
          },
          'PatientCharacteristicBirthdateBirthDate_precondition_25' => {
            'title' => 'birth date',
            'description' => 'Patient Characteristic Birthdate=> birth date',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.2.3.4',
            'property' => 'birthtime',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_birthdate',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicBirthdateBirthDate',
            'inline_code_list' => {
              'LOINC' => [
                '21112-8'
              ]
            },
            'temporal_references' => [
              {
                'type' => 'SBS',
                'reference' => 'MeasurePeriod',
                'range' => {
                  'type' => 'IVL_PQ',
                  'high' => {
                    'type' => 'PQ',
                    'unit' => 'a',
                    'value' => '17',
                    'inclusive?' => true,
                    'derived?' => false
                  }
                }
              }
            ]
          },
          'EncounterPerformedFaceToFaceInteraction_precondition_27' => {
            'title' => 'Face-to-Face Interaction',
            'description' => 'Encounter, Performed=> Face-to-Face Interaction',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.4.5.6',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedFaceToFaceInteraction',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedOfficeVisit_precondition_29' => {
            'title' => 'Office Visit',
            'description' => 'Encounter, Performed=> Office Visit',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.3.4.5',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedOfficeVisit',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_31' => {
            'title' => 'Preventive Care Services-Individual Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services-Individual Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.12.13.14',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesIndividualCounseling',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_33' => {
            'title' => 'Preventive Care- Initial Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care- Initial Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.13.14.15',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareInitialOfficeVisit0To17',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_35' => {
            'title' => 'Preventive Care - Established Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care - Established Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.14.15.16',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_37' => {
            'title' => 'Preventive Care Services - Group Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services - Group Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.15.16.17',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesGroupCounseling',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedHomeHealthcareServices_precondition_39' => {
            'title' => 'Home Healthcare Services',
            'description' => 'Encounter, Performed=> Home Healthcare Services',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.6.7.8',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedHomeHealthcareServices',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'PatientCharacteristicBirthdateBirthDate_precondition_44' => {
            'title' => 'birth date',
            'description' => 'Patient Characteristic Birthdate=> birth date',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.2.3.4',
            'property' => 'birthtime',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_birthdate',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicBirthdateBirthDate',
            'inline_code_list' => {
              'LOINC' => [
                '21112-8'
              ]
            },
            'temporal_references' => [
              {
                'type' => 'SBS',
                'reference' => 'MeasurePeriod',
                'range' => {
                  'type' => 'IVL_PQ',
                  'low' => {
                    'type' => 'PQ',
                    'unit' => 'a',
                    'value' => '3',
                    'inclusive?' => true,
                    'derived?' => false
                  }
                }
              }
            ]
          },
          'PatientCharacteristicBirthdateBirthDate_precondition_46' => {
            'title' => 'birth date',
            'description' => 'Patient Characteristic Birthdate=> birth date',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.2.3.4',
            'property' => 'birthtime',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_birthdate',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicBirthdateBirthDate',
            'inline_code_list' => {
              'LOINC' => [
                '21112-8'
              ]
            },
            'temporal_references' => [
              {
                'type' => 'SBS',
                'reference' => 'MeasurePeriod',
                'range' => {
                  'type' => 'IVL_PQ',
                  'high' => {
                    'type' => 'PQ',
                    'unit' => 'a',
                    'value' => '11',
                    'inclusive?' => true,
                    'derived?' => false
                  }
                }
              }
            ]
          },
          'EncounterPerformedFaceToFaceInteraction_precondition_48' => {
            'title' => 'Face-to-Face Interaction',
            'description' => 'Encounter, Performed=> Face-to-Face Interaction',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.4.5.6',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedFaceToFaceInteraction',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedOfficeVisit_precondition_50' => {
            'title' => 'Office Visit',
            'description' => 'Encounter, Performed=> Office Visit',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.3.4.5',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedOfficeVisit',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_52' => {
            'title' => 'Preventive Care Services-Individual Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services-Individual Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.12.13.14',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesIndividualCounseling',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_54' => {
            'title' => 'Preventive Care- Initial Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care- Initial Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.13.14.15',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareInitialOfficeVisit0To17',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_56' => {
            'title' => 'Preventive Care - Established Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care - Established Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.14.15.16',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_58' => {
            'title' => 'Preventive Care Services - Group Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services - Group Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.15.16.17',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesGroupCounseling',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedHomeHealthcareServices_precondition_60' => {
            'title' => 'Home Healthcare Services',
            'description' => 'Encounter, Performed=> Home Healthcare Services',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.6.7.8',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedHomeHealthcareServices',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'PatientCharacteristicBirthdateBirthDate_precondition_65' => {
            'title' => 'birth date',
            'description' => 'Patient Characteristic Birthdate=> birth date',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.2.3.4',
            'property' => 'birthtime',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_birthdate',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicBirthdateBirthDate',
            'inline_code_list' => {
              'LOINC' => [
                '21112-8'
              ]
            },
            'temporal_references' => [
              {
                'type' => 'SBS',
                'reference' => 'MeasurePeriod',
                'range' => {
                  'type' => 'IVL_PQ',
                  'low' => {
                    'type' => 'PQ',
                    'unit' => 'a',
                    'value' => '12',
                    'inclusive?' => true,
                    'derived?' => false
                  }
                }
              }
            ]
          },
          'PatientCharacteristicBirthdateBirthDate_precondition_67' => {
            'title' => 'birth date',
            'description' => 'Patient Characteristic Birthdate=> birth date',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.2.3.4',
            'property' => 'birthtime',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_birthdate',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicBirthdateBirthDate',
            'inline_code_list' => {
              'LOINC' => [
                '21112-8'
              ]
            },
            'temporal_references' => [
              {
                'type' => 'SBS',
                'reference' => 'MeasurePeriod',
                'range' => {
                  'type' => 'IVL_PQ',
                  'high' => {
                    'type' => 'PQ',
                    'unit' => 'a',
                    'value' => '17',
                    'inclusive?' => true,
                    'derived?' => false
                  }
                }
              }
            ]
          },
          'EncounterPerformedFaceToFaceInteraction_precondition_69' => {
            'title' => 'Face-to-Face Interaction',
            'description' => 'Encounter, Performed=> Face-to-Face Interaction',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.4.5.6',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedFaceToFaceInteraction',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedOfficeVisit_precondition_71' => {
            'title' => 'Office Visit',
            'description' => 'Encounter, Performed=> Office Visit',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.3.4.5',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedOfficeVisit',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareServicesIndividualCounseling_precondition_73' => {
            'title' => 'Preventive Care Services-Individual Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services-Individual Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.12.13.14',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesIndividualCounseling',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareInitialOfficeVisit0To17_precondition_75' => {
            'title' => 'Preventive Care- Initial Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care- Initial Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.13.14.15',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareInitialOfficeVisit0To17',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17_precondition_77' => {
            'title' => 'Preventive Care - Established Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care - Established Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.14.15.16',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedPreventiveCareServicesGroupCounseling_precondition_79' => {
            'title' => 'Preventive Care Services - Group Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services - Group Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.15.16.17',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesGroupCounseling',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          },
          'EncounterPerformedHomeHealthcareServices_precondition_81' => {
            'title' => 'Home Healthcare Services',
            'description' => 'Encounter, Performed=> Home Healthcare Services',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.6.7.8',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedHomeHealthcareServices',
            'temporal_references' => [
              {
                'type' => 'DURING',
                'reference' => 'MeasurePeriod'
              }
            ]
          }
        },
        'source_data_criteria' => {
          'PatientCharacteristicBirthdateBirthDate' => {
            'title' => 'birth date',
            'description' => 'Patient Characteristic Birthdate=> birth date',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.2.3.4',
            'property' => 'birthtime',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_birthdate',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicBirthdateBirthDate',
            'inline_code_list' => {
              'LOINC' => [
                '21112-8'
              ]
            }
          },
          'EncounterPerformedOfficeVisit' => {
            'title' => 'Office Visit',
            'description' => 'Encounter, Performed=> Office Visit',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.3.4.5',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedOfficeVisit'
          },
          'EncounterPerformedPreventiveCareInitialOfficeVisit0To17' => {
            'title' => 'Preventive Care- Initial Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care- Initial Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.13.14.15',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareInitialOfficeVisit0To17'
          },
          'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17' => {
            'title' => 'Preventive Care - Established Office Visit, 0 to 17',
            'description' => 'Encounter, Performed=> Preventive Care - Established Office Visit, 0 to 17',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.14.15.16',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareEstablishedOfficeVisit0To17'
          },
          'EncounterPerformedPreventiveCareServicesIndividualCounseling' => {
            'title' => 'Preventive Care Services-Individual Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services-Individual Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.12.13.14',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesIndividualCounseling'
          },
          'EncounterPerformedPreventiveCareServicesGroupCounseling' => {
            'title' => 'Preventive Care Services - Group Counseling',
            'description' => 'Encounter, Performed=> Preventive Care Services - Group Counseling',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.15.16.17',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedPreventiveCareServicesGroupCounseling'
          },
          'EncounterPerformedFaceToFaceInteraction' => {
            'title' => 'Face-to-Face Interaction',
            'description' => 'Encounter, Performed=> Face-to-Face Interaction',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.4.5.6',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedFaceToFaceInteraction'
          },
          'DiagnosisActivePregnancy' => {
            'title' => 'Pregnancy',
            'description' => 'Diagnosis, Active=> Pregnancy',
            'standard_category' => 'diagnosis_condition_problem',
            'qds_data_type' => 'diagnosis_active',
            'code_list_id' => '1.5.6.7',
            'type' => 'conditions',
            'definition' => 'diagnosis',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'DiagnosisActivePregnancy'
          },
          'PhysicalExamFindingBmiPercentile' => {
            'title' => 'BMI percentile',
            'description' => 'Physical Exam, Finding=> BMI percentile',
            'standard_category' => 'physical_exam',
            'qds_data_type' => 'physical_exam',
            'code_list_id' => '1.7.8.9',
            'type' => 'physical_exams',
            'definition' => 'physical_exam',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PhysicalExamFindingBmiPercentile'
          },
          'PhysicalExamFindingHeight' => {
            'title' => 'Height',
            'description' => 'Physical Exam, Finding=> Height',
            'standard_category' => 'physical_exam',
            'qds_data_type' => 'physical_exam',
            'code_list_id' => '1.8.9.10',
            'type' => 'physical_exams',
            'definition' => 'physical_exam',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PhysicalExamFindingHeight'
          },
          'PhysicalExamFindingWeight' => {
            'title' => 'Weight',
            'description' => 'Physical Exam, Finding=> Weight',
            'standard_category' => 'physical_exam',
            'qds_data_type' => 'physical_exam',
            'code_list_id' => '1.9.10.11',
            'type' => 'physical_exams',
            'definition' => 'physical_exam',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PhysicalExamFindingWeight'
          },
          'InterventionPerformedCounselingForNutrition' => {
            'title' => 'Counseling for Nutrition',
            'description' => 'Intervention, Performed=> Counseling for Nutrition',
            'standard_category' => 'procedure',
            'qds_data_type' => 'procedure_performed',
            'code_list_id' => '1.10.11.12',
            'type' => 'interventions',
            'definition' => 'intervention',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'InterventionPerformedCounselingForNutrition'
          },
          'InterventionPerformedCounselingForPhysicalActivity' => {
            'title' => 'Counseling for Physical Activity',
            'description' => 'Intervention, Performed=> Counseling for Physical Activity',
            'standard_category' => 'procedure',
            'qds_data_type' => 'procedure_performed',
            'code_list_id' => '1.11.12.13',
            'type' => 'interventions',
            'definition' => 'intervention',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'InterventionPerformedCounselingForPhysicalActivity'
          },
          'EncounterPerformedHomeHealthcareServices' => {
            'title' => 'Home Healthcare Services',
            'description' => 'Encounter, Performed=> Home Healthcare Services',
            'standard_category' => 'encounter',
            'qds_data_type' => 'encounter',
            'code_list_id' => '1.6.7.8',
            'type' => 'encounters',
            'definition' => 'encounter',
            'status' => 'performed',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'EncounterPerformedHomeHealthcareServices'
          },
          'OccurrenceAPregnancy1' => {
            'title' => 'Pregnancy',
            'description' => 'Diagnosis, Active=> Pregnancy',
            'standard_category' => 'diagnosis_condition_problem',
            'qds_data_type' => 'diagnosis_active',
            'code_list_id' => '1.5.6.7',
            'type' => 'conditions',
            'definition' => 'diagnosis',
            'status' => 'active',
            'hard_status' => false,
            'negation' => false,
            'specific_occurrence' => 'A',
            'specific_occurrence_const' => 'DIAGNOSIS_ACTIVE_PREGNANCY',
            'source_data_criteria' => 'OccurrenceAPregnancy1'
          },
          'PatientCharacteristicSexOncAdministrativeSex' => {
            'title' => 'ONC Administrative Sex',
            'description' => 'Patient Characteristic Sex=> ONC Administrative Sex',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '2.16.840.1.113762.1.4.1',
            'property' => 'gender',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_gender',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicSexOncAdministrativeSex',
            'value' => {
              'type' => 'CD',
              'system' => 'Administrative Sex',
              'code' => 'F'
            }
          },
          'PatientCharacteristicRaceRace' => {
            'title' => 'Race',
            'description' => 'Patient Characteristic Race=> Race',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '2.16.840.1.114222.4.11.836',
            'property' => 'race',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_race',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicRaceRace',
            'inline_code_list' => {
              'CDC Race' => [
                '1002-5',
                '2028-9',
                '2054-5',
                '2076-8',
                '2106-3',
                '2131-1'
              ]
            }
          },
          'PatientCharacteristicEthnicityEthnicity' => {
            'title' => 'Ethnicity',
            'description' => 'Patient Characteristic Ethnicity=> Ethnicity',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '1.1.2.3',
            'property' => 'ethnicity',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_ethnicity',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicEthnicityEthnicity',
            'inline_code_list' => {
              'CDC Race' => [
                '2135-2',
                '2186-5'
              ]
            }
          },
          'PatientCharacteristicPayerPayer' => {
            'title' => 'Payer',
            'description' => 'Patient Characteristic Payer=> Payer',
            'standard_category' => 'individual_characteristic',
            'qds_data_type' => 'individual_characteristic',
            'code_list_id' => '2.16.840.1.114222.4.11.3591',
            'property' => 'payer',
            'type' => 'characteristic',
            'definition' => 'patient_characteristic_payer',
            'hard_status' => false,
            'negation' => false,
            'source_data_criteria' => 'PatientCharacteristicPayerPayer',
            'inline_code_list' => {
              'Source of Payment Typology' => %w[1 2 349]
            }
          }
        }
      }
      hqmf_document { hqmf_doc }
      oid_list = ['2.16.840.1.113762.1.4.1',
                  '2.16.840.1.114222.4.11.836',
                  '1.1.2.3',
                  '2.16.840.1.114222.4.11.3591',
                  '1.2.3.4',
                  '1.3.4.5',
                  '1.4.5.6',
                  '1.5.6.7',
                  '1.6.7.8',
                  '1.7.8.9',
                  '1.8.9.10',
                  '1.9.10.11',
                  '1.10.11.12',
                  '1.11.12.13',
                  '1.12.13.14',
                  '1.13.14.15',
                  '1.14.15.16',
                  '1.15.16.17']
      oids { oid_list }
      pop_ids = { 'IPP' => 'F2666FD4-EB1F-11E7-8C3F-9A214CF093AE',
                  'DENOM' => 'F7D7DC82-EB1F-11E7-8C3F-9A214CF093AE',
                  'NUMER' => 'FC6D029A-EB1F-11E7-8C3F-9A214CF093AE',
                  'DENEX' => '0163BB04-EB20-11E7-8C3F-9A214CF093AE' }
      population_ids { pop_ids }
    end
  end
end
