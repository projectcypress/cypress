// Cypress specific JS functions
(function($) {

  $.cypress = {};
  $.cypress.addPoll = function(url, table_url, resolution) {
    setTimeout(function() {
      $.cypress.pollResult(url, table_url, resolution);
    }, 2000);
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

  $.cypress.pollResult = function(url, table_url, resolution) {

    $.getJSON(url, function(data) {
      // Update the progress bar
      if (data.percent_completed > 0)
        $("#loading_progress .ui-progressbar-value").show();
      $("#loading_progress .ui-progressbar-value").animate({ width: data.percent_completed + '%' }, 'slow');

      var pollAgain = false;
      // data can be a single result row as returned by the measures controller
      // or a structure containing an array of results as returned by the vendor controller
      if (data.results) {
        // Vendor view page
        for (var i = 0; i < data.results.length; i++) {
          pollAgain |= $.cypress.updateResults(data.results[i]);
        }
        //poll until the patient records are populated
        if (data.patients.length < 1){
          pollAgain = true;
        }
      } else if (data.percent_completed < 100) {
        pollAgain = true;
      } else {
        // Measure view or master patient index
        pollAgain |= $.cypress.updateResults(data);
        if (!pollAgain) {
          // calculation is complete so show patient list table if an URL was provided
          if (table_url) {
            $.cypress.updatePatientTable(table_url);
          }
        }
      }

      if (pollAgain) {
        // true if any result is not yet available
        $.cypress.addPoll(url, table_url, resolution);
      } else {
        // if we're done with this particular task, execute whatever resolution function that was specified
        if (resolution != undefined)
          resolution();
      }
    });
  }

  $.cypress.updatePatientTable = function(url) {
    $.ajax({ url: url,
             type: "GET",
             dataType: 'html',
             success: function(res){
              $('#product_test_patients').html(res);
              $('#loading_dialog').dialog('close');
             },
             error: function(xhr, err) {
              $('#loading_dialog').dialog('close');
              alert("Patient table update failed");
             }
           });
  }

  $.cypress.filterPatients = function(url) {
    $.cypress.updatePatientTable(url);
  }

  $.cypress.showMenu = function(origin, menu) {
    position = origin.offset();

    dialog = menu.dialog({
      position: {my: "right top", at: "left top", of: origin},
      resizable: false,
      dialogClass: 'dialog-menuwindow',
      minHeight: false,
      minWidth: false,
      width: origin.outerWidth()
    });
    dialog.css('padding', '2px');
    dialog.parent().hover(
      function() {},
      function() { dialog.dialog('close'); }
    );
  }

  $.cypress.textForUnit = function(value, temporal, plural) {
      decoder = {'a':'year','mo':'month','wk':'week','d':'day','h':'hour','min':'minute','s':'second'};
      if(temporal) value = decoder[value];
      if(temporal && plural) value += 's';
      return value;
    }

    $.cypress.textForValue = function(value, temporal) {
      return (value['inclusive?'] ? '=' : '') + " " + value.value + (value.unit != null ? ' ' + $.cypress.textForUnit(value.unit,temporal,value.value>1) +' ' : '')
    }

    $.cypress.humanizeCategory = function(catagory) {
      return catagory.replace(/_/g,' ');
    }
    $.cypress.textForRange = function(range, temporal) {
      if ((range.high != null) && (range.low != null)) {
        if (range.high.value === range.low.value && range.high['inclusive?'] && range.low['inclusive?'])
          return "=" + range.low.value;
        else
          return ">" + $.cypress.textForValue(range.low,temporal) + " and <" + $.cypress.textForValue(range.high,temporal);
      } else {
        if (range.high != null)
          return "<" + $.cypress.textForValue(range.high,temporal);
        if (range.low != null)
          return ">" + $.cypress.textForValue(range.low,temporal);
        if (range.value != null)
          return "=" + range.value;
        return '';
      }
    }

    $.cypress.renderMeasureJSON = function(data) {
        var measure = data;
        var elemParent;
        var addParamItems = function(obj,elemParent,container) {
          var conjunction, obj, items, subset_operator, _i, _len, _ref;
          items = obj["items"];
          if ((obj.title != null)) {
            if ((obj.subset_operators != null)) {
              _ref = obj.subset_operators;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                subset_operator = _ref[_i];
                $(elemParent).append("<span class='" + subset_operator.type + "'>" +
                (
                  subset_operator.type + ' ' +
                  (
                    subset_operator.value ? $.cypress.textForRange(subset_operator.value, false) : ''
                  ) +
                  ' of'
                )
                + "</span>"
                );
              }
            }
            if ((obj.children_criteria != null)) {
              items = [];
              if (obj.children_criteria.length > 0){
                conjunction = obj.derivation_operator == 'XPRODUCT' ? 'and' : 'or';
                items.push({'conjunction': conjunction, 'items': obj.children_criteria, 'negation':null})
              }
            } else {
              if (obj.temporal_references) {
                items = $.map(obj.temporal_references,
                  function(temporal_reference){
                    return {
                      conjunction: temporal_reference.type,
                      items: [temporal_reference.reference],
                      temporal: true,
                      title: (
                        (
                          temporal_reference.range ? $.cypress.textForRange(temporal_reference.range,true) : ''
                        ) +
                        ({
                          DURING:'During',SBS:'Starts Before Start of',SAS:'Starts After Start of',SBE:'Starts Before End of',
                          SAE:'Starts After End of',EBS:'Ends Before Start of',EAS:'Ends After Start of',EBE:'Ends Before End of',
                          EAE:'Ends After End of',SDU:'Starts During',EDU:'Ends During',ECW:'Ends Concurrent with',
                          SCW:'Starts Concurrent with',CONCURRENT:'Concurrent with'
                        })[temporal_reference.type] +
                        (temporal_reference.reference == 'MeasurePeriod' ? ' Measure Period' : '')
                      )
                    }
                  }
                );
              }
              if (!obj.temporal){
                elemParent = $("#ph_tmpl_paramGroup").tmpl().appendTo(elemParent).find(".paramItem:last");
                $('#ph_tmpl_data_criteria_logic').tmpl(obj).appendTo(elemParent);
              }
            }
          }
          var neg = obj.negation || false;
          if ($.isArray(items)) {
            conjunction = obj['conjunction'];
            if (items.length > 1 && !(container != null)) {
              elemParent = $('#ph_tmpl_paramGroup').tmpl().appendTo(elemParent).find(".paramItem:last");
            }
            if (neg) {
              $(elemParent).append("<span class='not'>not</span>");
            }
            return $.each(items, function(i, node) {
              var next;
              if (node.temporal) {
                $(elemParent).append("<span class='" + node.conjunction + "'>" + node.title + "</span>");
              }
              addParamItems(node, elemParent);
              if (i < items.length - 1 && !node.temporal) {
                next = items[i + 1];
                if (!conjunction) {
                  conjunction = node.conjunction;
                }
                return $(elemParent).append("<span class='" + conjunction + "'>" + conjunction + "</span>");
              }
            });
          };
        } // end addParamItems

        if (data.population) {
          elemParent = $("#ph_tmpl_paramGroup").tmpl({}).appendTo("#eligibilityMeasureItems").find(".paramItem:last");
          addParamItems(data.population,elemParent,elemParent);
          elemParent.parent().addClass("population");
        }

        if (!$.isEmptyObject(data.denominator)) {
          $("#eligibilityMeasureItems").append("<span class='and'>and</span>");
          addParamItems(data.denominator,$("#eligibilityMeasureItems"));
        }

        if (data.numerator) {
          addParamItems(data.numerator,$("#outcomeMeasureItems"));
        }

        if (!$.isEmptyObject(data.exclusions)) {
          addParamItems(data.exclusions,$("#exclusionMeasureItems"));
          $("#exclusionMeasureItems").hide();
          $("#exclusionPanel").show();
        }
     }

})( jQuery );

function scrollToElement(element){
  var offsetFromTop = 200;
  if ($(element).length) {
    try {
       $(element).animate({ scrollTop: $(element).scrollTop() - $(element).offset().top }, { duration: 'slow', easing: 'swing'});
       $('html,body').animate({ scrollTop: $(element).offset().top - offsetFromTop }, { duration: 1000, easing: 'swing'});
       window.location.hash = element;
     } catch(e) {}
  }
}

// Faster version of scrollToElement,
function jumpToElement(element){
  var jumpThreshold = 5000;
  var offsetFromTop = 200;

  if ($(element).length) {
    try {
      var ot = $(element).offset().top;
      var st = $('body').scrollTop();
      if (Math.abs(ot - st) > jumpThreshold) {
        $('html,body').scrollTop(ot > st ? ot - 400 : ot + 200);
      }
      $(element).animate({ scrollTop: $(element).scrollTop() - $(element).offset().top }, { duration: 'slow', easing: 'swing'});
      if (Math.abs(ot - st) > offsetFromTop) {
        $('html,body').animate({ scrollTop: $(element).offset().top - offsetFromTop }, { duration: 1000, easing: 'swing'});
      } else {
        return;
      }
     window.location.hash = element;
     } catch(e) {}
  }
}
