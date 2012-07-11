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
      position: [position.left, (position.top + $(origin).height() - 20 - $(window).scrollTop())],
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

    $.cypress.renderMeasureJSON = function(data) {
      var measure = data;
      var elemParent;
      var addParamItems = function(obj,elemParent,container) {
        var items = obj['and'] || obj['or'];
        if ($.isArray(items)) {
          var conjunction = obj['and'] ? 'and' : 'or';
          // add the grouping container
          if (!container) {elemParent = $("#ph_tmpl_paramGroup").tmpl({}).appendTo(elemParent).find(".paramItem:last");}
            $.each(items,function(i,node) {
              addParamItems(node,elemParent);
              if (i < items.length-1) {
                $(elemParent).append("<span class='"+conjunction+"'>"+conjunction+"</span>");
              }
            });
        } 
        else {
          // we dont have a nested measure clause, add the item to the bottom of the list
          if (!elemParent.hasClass("paramItem")) {
            elemParent = $("#ph_tmpl_paramGroup").tmpl({}).appendTo(elemParent).find(".paramItem:last");
          }
          $("#ph_tmpl_paramItem").tmpl(obj).appendTo(elemParent);
        }
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

    }
})( jQuery );

