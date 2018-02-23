// Adds common utility functions to the root JS object. These are then
// available for use by the map-reduce functions for each measure.
// lib/qme/mongo_helpers.rb executes this function on a database
// connection.

var root = this;

root.map = function(record, population, denominator, numerator, exclusion, denexcep, msrpopl, observ, occurrenceId, isContinuousVariable) {
  var value = {IPP: 0, patient_id: record._id,
               medical_record_id: record.medical_record_number,
               first: record.first, last: record.last, gender: record.gender,
               birthdate: record.birthdate, test_id: record.test_id,
               provider_performances: record.provider_performances,
               race: record.race, ethnicity: record.ethnicity, languages: record.languages,
               payer: extract_payer(record)};

  if (isContinuousVariable) {
    value = calculateCV(record, population, msrpopl, observ, occurrenceId, value)
  } else {
    value = calculate(record, population, denominator, numerator, exclusion, denexcep, occurrenceId, value)
  }

  if (typeof Logger != 'undefined') {
    value['logger'] = Logger.logger
    value['rationale'] = Logger.rationale
  }
  
  emit(ObjectId(), value);
};

root.extract_payer = function(record) {
  var payer = {};
  if(record.insurance_providers && record.insurance_providers.length > 0){
    var ip = record.insurance_providers[0];
    if(ip.codes.SOP && ip.codes.SOP.length >0){
      payer["code"] = ip.codes.SOP[0];
      payer["codeSystem"] = "SOP";
    }
  }
  return payer;
};

root.calculate = function(record, population, denominator, numerator, exclusion, denexcep, occurrenceId, value) {
  
  value = _.extend(value, {DENOM: 0, NUMER: 0, DENEXCEP: 0, DENEX: 0, antinumerator: 0});
  
  var ipp = population()
  if (hqmf.SpecificsManager.validate(ipp)) {
    value.IPP = hqmf.SpecificsManager.countUnique(occurrenceId, ipp);
    var denom = hqmf.SpecificsManager.intersectSpecifics(denominator(), ipp, occurrenceId);
    if (hqmf.SpecificsManager.validate(denom)) {
      
      value.DENOM = hqmf.SpecificsManager.countUnique(occurrenceId, denom);
      var exclusions = hqmf.SpecificsManager.intersectSpecifics(exclusion(), denom, occurrenceId);
      if (hqmf.SpecificsManager.validate(exclusions)) {
        value.DENEX = hqmf.SpecificsManager.countUnique(occurrenceId, exclusions);
        denom = hqmf.SpecificsManager.exclude(occurrenceId, denom, exclusions);
      }

    }

    // we need to check the denominator again to make sure we still have viable candidates after 
    // exclusions have been removed
    if (hqmf.SpecificsManager.validate(denom)) {
      var numer = hqmf.SpecificsManager.intersectSpecifics(numerator(), denom, occurrenceId);
      if (hqmf.SpecificsManager.validate(numer)) {
        value.NUMER = hqmf.SpecificsManager.countUnique(occurrenceId, numer);
      }
      
      var excep = hqmf.SpecificsManager.intersectSpecifics(denexcep(), denom, occurrenceId);
      if (hqmf.SpecificsManager.validate(excep)) {
        excep = hqmf.SpecificsManager.exclude(occurrenceId, excep, numer);
        value.DENEXCEP = hqmf.SpecificsManager.countUnique(occurrenceId, excep);
        denom = hqmf.SpecificsManager.exclude(occurrenceId, denom, excep);
      }
      value.antinumerator = value.DENOM-value.NUMER;
    }
      
  }
  return value;
};

root.calculateCV = function(record, population, msrpopl, observ, occurrenceId, value) {
  value = _.extend(value, {MSRPOPL: 0, values: []});
  
  var ipp = population()
  if (hqmf.SpecificsManager.validate(ipp)) {
    value.IPP = hqmf.SpecificsManager.countUnique(occurrenceId, ipp);
    var measurePopulation = hqmf.SpecificsManager.intersectSpecifics(msrpopl(), ipp, occurrenceId);
    if (hqmf.SpecificsManager.validate(measurePopulation)) {
      var observations = observ(measurePopulation.specificContext);
      value.MSRPOPL = hqmf.SpecificsManager.countUnique(occurrenceId, measurePopulation);
      value.values = observations;
    }
  }
  return value;
};

 
