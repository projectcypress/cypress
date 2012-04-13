
/* Loop over all of the measures in coverage and fill the values of the matrix */
function updateMatrix() {
    for (measure in coverage)
        updateMatrixByMeasure(measure);
}

/* Update the bucket values for the given measure in the matrix */
function updateMatrixByMeasure(measure) {
    var mappedPatients = [];
    var totalBuckets = {
        "numerator" : 0,
        "denominator" : 0,
        "antinumerator" : 0,
        "exclusions" : 0
    };

    // Loop through each patient included in the set
    $.each(minimalPatients, function(i, patient) {
        // If the patient touches this measure, add their bucket values to the totals
        if (patient._id in coverage[measure])
            $.each(coverage[measure][patient._id], function(bucket, patientBucketValue) {
                totalBuckets[bucket] += patientBucketValue;
            });
    });

    // Apply updated bucket values to the actual entries in the matrix
    var measureRow = $("#" + measure);
    $.each(totalBuckets, function(bucket, total) {
        measureRow.children("." + bucket).html(total);
    });
}

/* When patients are added or removed from the minimal set, update the appearance of the overflow buttons */
function updateOverflowButtons() {
    // Update the text of the adding and removing buttons
    var usedOverflow = minimalPatients.length - minimalCount;
    var totalOverflow = overflow.length + usedOverflow;
    $("#add_patient").text("+ (" + overflow.length + "/" + totalOverflow + ")");
    $("#remove_patient").text("- (" + usedOverflow + "/" + totalOverflow + ")");

    // Enable/Disable the add button as the overflow list becomes filled or empty
    if (overflow.length == 0)
        $("#add_patient").addClass("disabled");
    else if (overflow.length == 1)
        $("#add_patient").removeClass("disabled");
    // Enable/Disable the remove button as the minimalPatients list becomes filled or empty
    if (minimalPatients.length == minimalCount)
        $("#remove_patient").addClass("disabled");
    else if (minimalPatients.length == (minimalCount + 1))
        $("#remove_patient").removeClass("disabled");
}

/* Add a patient from overflow to the minimal set */
function addMinimalPatient() {
    // If we've exhausted the overflow list, we can't add anymore
    if (overflow.length < 1)
        return false;

    // Select a random patient and move them from the overflow list to the used list
    var randomIndex = Math.floor(Math.random() * overflow.length);
    var patient = overflow.splice(randomIndex, 1)[0];
    minimalPatients.push(patient);

    return patient;
}

/* Remove one of the extra patients from the minimal set */
function removeMinimalPatient() {
    // If we're at the minimum set, don't remove any more patients
    if (minimalPatients.length == minimalCount)
        return false;

    // Drop the patient from the used list and put them back in overflow
    var patient = minimalPatients.pop();
    overflow.push(patient);

    return patient;
}

/* Return the HTML for a new row that describes the given patient to be inserted into the minimal patient matrix */
function createMinimalPatientRow(patient) {
    // Gather necessary information for our new entry
    var birthdate = new Date(patient.birthdate);
    var formattedBirthdate = (birthdate.getMonth() + 1) + "/" + birthdate.getDate() + "/" + birthdate.getFullYear();

    // Put the pieces of the new row together
    var patientRow = $("<tr id='" + patient._id + "' class='patient'>" +
        "<td>" + patient.last + "</td>" +
        "<td>" + patient.first + "</td>" +
        "<td style='text-align:center'>" + formattedBirthdate + "</td>" +
        "<td style='text-align:center'>" + patient.gender + "</td>" +
        "</tr>");

    // Add the new row along with a hidden input to include the patient in the set of records to be cloned
    $("#minimal_patients_table").append("<input type='hidden' name='patient_ids[]' value='" + patient.patient_id + "'>");
    $("#minimal_patients_table").append(patientRow);

    // Attach the hover behavior to the new row. TODO - Why doesn't jQuery's .on propagate the hover event?
    patientRow = $("#minimal_patients_table tr:last");
    patientRow.children("td").on("mouseenter mouseout", highlightMeasures);
}

/* Highlight all measure rows in the minimal set matrix that are affected by the triggering patient */
function highlightMeasures() {
    // Find the patient from the ID attached to the row that triggered this event
    var patientId = $(this).closest('tr').prop("id");
    var patient;
    $.each(minimalPatients, function(i, minimalPatient) {
        if (minimalPatient._id == patientId) {
            patient = minimalPatient;
            return;
        }
    });

    // Find all of the measures this patient affects and create an accessor to touch the measure rows
    var measureRows = patient.measures.join(", #");
    $("#" + measureRows + " td").toggleClass('highlight');
}

/* Highlight all patient rows in the minimal set matrix that are affected by the triggering measure */
function highlightPatients() {
    // Find the measure from the ID attached to the row that triggered this event
    var measureId = $(this).closest('tr').prop("id");

    // Collect all of the currently included patients from the given measure
    var patients = [];
    for (p in minimalPatients) {
        var patient = minimalPatients[p];
        if (patient._id in coverage[measureId])
            patients.push(patient._id);
    };

    // Create an accessor to highlight all of the touched patient rows
    var patientRows = patients.join(", #");
    $("#" + patientRows + " td").toggleClass('highlight');
}






