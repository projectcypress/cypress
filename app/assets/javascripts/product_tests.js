// Test creation wizard functions
(function($) {

    $.testWizard = {};
  
    $.testWizard.updateMeasureSet = function(testType) {
        $('#measures').empty().html('<div class="busy">Finding measures for test type ' + testType + '...</h3>');
        var ids = [];
        // get the measures for this type of test
        $.ajax({
            url: "/measures/by_type",
            type: "POST",
            data: {
                type: testType
            },
            dataType: 'script',
            error: function(xhr, err) {
                alert("Sorry, we can't currently produce measures by type:'" + testType + "'\n" + err);
            }
        });
    };

  
/*    commented out functionality related to the minimal patient set since
 *    that screen is no longer part of the wizard sequence
     $.testWizard.updateMinimalPatientSet = function() {
        $('#measure_coverage').empty().html('<div class="busy">Finding appropriate patients...</h3>');
        var ids = [];
        $('.measure_cb:checked').each(function(i,e) {
            var id = $(e).attr('id');
            ids.push(id.substr(id.lastIndexOf('_')+1));
        });
        // get the needed num/den/exc for each of the selected measures
        $.ajax({
            url: "/measures/minimal_set",
            type: "POST",
            data: {
                measure_ids: ids,
                product_id: $('#product_test_product_id').val(),
                num_records: $('#total_records').val()
            },
            dataType: 'script',
            error: function(xhr, err) {
                alert("Sorry, we can't currently calculate large numbers of quality measures:\n" + err);
            }
        });
    };
*/
    $.testWizard.updateProgressBar = function(screen) {
        switch (screen) {
            case "first":
                $('#currentStep').html(1);
                $('#back').addClass('disabled').find('input').attr('disabled',true).css("color","silver");
                break;
            case "wizard-measures-screen":
                $('#currentStep').html(2);
                $('#back').removeClass('disabled').find('input').removeAttr('disabled').css("color","green");
                break;
//            case "wizard-workflow-screen":
//                $('#currentStep').html(3);
//                break;
//            case "wizard-patients-automated-screen":
//            case "wizard-patients-manual-screen":
//            case "wizard-patients-byod-screen":
//                $('#currentStep').html(4);
//                break;
        }
    }
  
})( jQuery );

$(document).ready(function() {
//    $('[name=population_name]').change(function() {
//        $('[name=population_description]').addClass("required");
//    });
//    $('[name=population_description]').change(function() {
//        $('[name=population_name]').addClass("required");
//    });

    // set the default choice by invoking a click on workflow 2
//    $('label[for=wf2]').trigger("click");

    var cache = {}; // caching inputs for the visited steps

    // Variables for the minimal patient set
//    var minimalCount = 0;
//    var minimalPatients = [];
//    var usedOverflow = [];
//    var coverage = [];


    $.fx.off = true; // disable the annoying animations the wizard uses

// establish the form wizard
    $('#new_product_test').formwizard({
        // !important - otherwise the rails form processing
        // doesn't redirect properly.  set formPluginEnabled to false
        formPluginEnabled: false,
        validationEnabled: true,
        historyEnabled : false, // unless you want back button support ala BBQ
        focusFirstInput : true,
        formOptions : {
            dataType: 'json',
            resetForm: true
        },
        textSubmit: 'Done',
        disableUIStyles: true,
        validationOptions: {
            rules: {
                "product_test[name]": "required",
//                "product_test[patient_population]": "required",
                "product_test[measure_ids][]": "required"
            },
            errorClass: "validationErrors",
            messages: {
                "product_test[name]": {
                    required:"The test needs a name."
                },
//                "product_test[patient_population]": {
//                    required:"Choose a patient population."
//                },
                "product_test[measure_ids][]": {
                    required:"You must choose at least one quality measure."
                }
            },
            errorPlacement: function(error, element) {
                error.appendTo( $('#validationErrorMessages') );
            }
        }
    }).bind("step_shown", function(event,data){ //TODO still need to hook up validation
        // do screen-specific functions here
        if (data.currentStep == "wizard-measures-screen") {
            $.testWizard.updateMeasureSet($('[name=type]:checked').val());
        }
//        if (data.currentStep == "wizard-patients-manual-screen") {
//            $.testWizard.updateMinimalPatientSet();
//        }
        // update the progress indicator
        $.testWizard.updateProgressBar(data.currentStep);

        if(data.isLastStep){ // if this is the last step...then
            $("#summaryContainer").empty().append("<ul/>"); // empty the container holding the
            $.each(data.activatedSteps, function(i, id){ // for each of the activated steps...do
                if(id === "wizard-summary-screen") return; // if it is the summary page then just return
                cache[id] = $("#" + id).find(".input"); // else, find the div:s with class="input" and cache them with a key equal to the current step id
                //cache[id].detach().appendTo('#summaryContainer').show().find(":input").removeAttr("disabled"); // detach the cached inputs and append them to the summary container, also show and enable them
                $('#summaryContainer').append("<li>"+cache[id].value+"</li>")
            });
        }else if(data.previousStep === "wizard-summary-screen"){ // if we are movin back from the summary page
            $.each(cache, function(id, inputs){ // for each of the keys in the cache...do
                var i = inputs.detach().appendTo("#" + id).find(":input");  // put the input divs back into their normal step
                if(id === data.currentStep){ // (we are moving back from the summary page so...) if enable inputs on the current step
                    i.removeAttr("disabled");
                }else{ // disable the inputs on the rest of the steps
                    i.attr("disabled","disabled");
                }
            });
            cache = {}; // empty the cache again
        }
    });
    $.testWizard.updateProgressBar("first");
    $('.edit_product_test').validate({
        rules: {
            "product_test[name]": "required"
        },
        errorClass: "validationErrors",
        messages: {
            "product_test[name]": {
                required:"The test needs a name."
            }
        },
        errorPlacement: function(error, element) {
            error.appendTo( $('#validationErrorMessages') );
        }
    });
});