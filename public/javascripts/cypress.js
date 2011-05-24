// Cypress specific JS functions
(function($) {

  $.cypress = {}
  $.cypress.addPoll = function(url) {
    setTimeout(function() {
      $.cypress.pollResult(url);
    }, 3000);
  }
  
  $.cypress.updateResultRow = function(result) {
    if (result.numerator=="?")
      return true;
    var resultRow = $("#"+result.measure_id);
    resultRow.find(".num").text(result.numerator);
    resultRow.find(".den").text(result.denominator);
    resultRow.find(".exc").text(result.exclusions);
    return false;
  }
    
  $.cypress.pollResult = function(url) {
    $.getJSON(url, function(data) {
      var pollAgain = false;
      // data can be a single resul row as returned by the measures controller
      // or a structure containing an array of results as returned by the vendor controller
      if (data.results) {
        for (i=0;i<data.results.length;i++) {
          pollAgain |= $.cypress.updateResultRow(data.results[i]);
        }
      } else {
        pollAgain |= $.cypress.updateResultRow(data);
      }
      if (pollAgain) {
        // true if any result is not yet available
        $.cypress.addPoll(url);
      }
    });
  }
  
})( jQuery );