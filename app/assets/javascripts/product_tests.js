// Test creation wizard functions
(function($) {

    $.testWizard = {};

    $.testWizard.updateMeasureSet = function(testType, bundle_id) {
        $("#measures").empty().html('<div class="busy">Finding measures for test type ' + testType + "...</h3>");
        var ids = [];
        // get the measures for this type of test
        $.ajax({
            url: "/measures/by_type?bundle_id=" + bundle_id,
            type: "POST",
            data: {
                type: testType
            },
            dataType: "script",
            error: function(xhr, textStatus, err) {
              alert("Sorry, we can't currently produce measures by type:'" + testType + "'\n" + err);
            }
        });
    };

    $.testWizard.updateProgressBar = function(screen) {
        switch (screen) {
            case "first":
                $('#currentStep').html(1);
                $('#back').addClass('disabled').attr('disabled',true);
                break;
            case "wizard-measures-screen":
                $('#currentStep').html(2);
                $('#back').removeClass('disabled').removeAttr('disabled');
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
            $.testWizard.updateMeasureSet($('[name=type]:checked').val(),$('[name=bundle_id]').val());
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
    // disableUIStyles doesn't prevent these classes from being added to the buttons.
    // we'll remove them here instead of overriding in the stylesheets.
    $("#navigation input").removeClass("ui-formwizard-button ui-wizard-content");
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

$(document).ready(function(){

    $('#bundle_id').change(function(){
        var d = effective_dates[$(this).selected().val()];
        var s = start_dates[$(this).selected().val()];
        var md = moment(d*1000).utc();
        var mds = moment(s*1000).utc();
        $("input[name='product_test[effective_date]']").val(d);
        $("#effective_date_end").html(md.calendar())
        $("#effective_date_start").html(mds.calendar());

    });
    $('#bundle_id').change();

});
