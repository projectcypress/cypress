// Cypress specific JS functions
(function($) {

  $.cypress = {}
  $.cypress.addPoll = function(measureId, url) {
    setTimeout(function() {
      $.cypress.pollResult(measureId, url);
    }, 3000);
  }
    
  $.cypress.pollResult = function(measureId, url) {
    $.getJSON(url, function(data) {
      if (data.numerator=="?") {
        $.cypress.addPoll(measureId, url);
      } else {
        var resultRow = $("#"+measureId);
        resultRow.find(".num").text(data.numerator);
        resultRow.find(".den").text(data.denominator);
        resultRow.find(".exc").text(data.exclusions);
      }
    });
  }
  
})( jQuery );