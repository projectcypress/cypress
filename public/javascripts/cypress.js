// Cypress specific JS functions
(function($) {

  $.cypress = {}
  $.cypress.addPoll = function(url, table_url) {
    setTimeout(function() {
      $.cypress.pollResult(url, table_url);
    }, 3000);
  }
  
  $.cypress.updateResults = function(result) {
    if (result.numerator=="?")
      return true;
    var resultRow = $("#"+result.measure_id);
    resultRow.find(".num").text(result.numerator);
    resultRow.find(".den").text(result.denominator);
    resultRow.find(".exc").text(result.exclusions);
    resultRow.find(".out").text(result.antinumerator);
    return false;
  }
    
  $.cypress.pollResult = function(url, table_url) {
    $.getJSON(url, function(data) {
      var pollAgain = false;
      // data can be a single result row as returned by the measures controller
      // or a structure containing an array of results as returned by the vendor controller
      if (data.results) {
        // Vendor view page
        for (i=0;i<data.results.length;i++) {
          pollAgain |= $.cypress.updateResults(data.results[i]);
        }
      } else {
        // Measure view page
        pollAgain |= $.cypress.updateResults(data);
        if (!pollAgain) {
          // calculation is complete so show patient list table
          if (table_url) {
            $.cypress.updatePatientTable(table_url);
          }
          else {
            $.cypress.updatePatientTable(url+"/patients");
          }
        }
      }
      if (pollAgain) {
        // true if any result is not yet available
        $.cypress.addPoll(url, table_url);
      }
    });
  }
  
  $.cypress.updatePatientTable = function(url) {
    $.ajax({ url: url,
             type: "GET",
             dataType: 'html',
             success: function(res){
               $('#vendor_patients').html(res);
             },
             error: function(xhr, err) {
               alert("Patient table update failed");
             }
           });
  }
  
})( jQuery );