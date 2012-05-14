// Test creation wizard functions
(function($) {

    $.testWizard = {};
  
    $.testWizard.tallyMeasureGroups = function() {
        var grandTotal = 0;
        $.each($('.measure_group'), function(index, item){
            var total = Math.max(0,$(this).find('input.measure_cb:checked').length);
            $('#' + $(item).attr('id') +'_group').prop('checked', $(this).find('input.measure_cb').length == total);
            grandTotal += total;
            $('#' + $(item).attr('id') +'_group_total').empty().html(total > 0 ? total : '');
        });
        $('#all_measures').prop('checked',$('#wizard-measures-screen input.measure_cb').length == grandTotal)
        // clear the coverage map
        $('#measure_coverage').empty()
        $('form').valid();
    };


  
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

    $.testWizard.updateDownloadFilename = function() {
        var download_filename = $('#product_test_name').val().replace(/ /g,"_") + "_" +
        $('#product_test_patient_population').val() + "_" +
        $('input[name=download_format]:checked').val() +
        '.zip';
        $('#download_filename').attr('readonly',true).val(download_filename);
    };

    $.testWizard.updateProgressBar = function(screen) {
        $('#step1,#step2,#step3,#step4').removeClass('complete current incomplete').addClass('incomplete');
        switch (screen) {
            case "first":
                $('#step1').removeClass('incomplete').addClass('current');
                break;
            case "wizard-measures-screen":
                $('#step1').removeClass('incomplete').addClass('complete');
                $('#step2').removeClass('incomplete').addClass('current');
                break;
            case "wizard-workflow-screen":
                $('#step1,#step2').removeClass('incomplete').addClass('complete');
                $('#step3').removeClass('incomplete').addClass('current');
                break;

            case "wizard-patients-automated-screen":
            case "wizard-patients-manual-screen":
            case "wizard-patients-byod-screen":
                $('#step1,#step2,#step3').removeClass('incomplete').addClass('complete');
                $('#step4').removeClass('incomplete').addClass('current');
                break;
        }
    }
  
})( jQuery );

$(document).ready(function() {
    // for handling the selection of measures from groups
    $('#all_measures').click(function () {
        $('#wizard-measures-screen input:checkbox').prop('checked', $(this).prop('checked'));
        $('.measure_group').prop('checked', $(this).prop('checked'));
        $.testWizard.tallyMeasureGroups();
    });
    $('.measure_group_all').click(function () {
        var groupName = $(this).attr('id');
        $(this).closest('div').find('input:checkbox').prop('checked', $(this).prop('checked'));
        $.testWizard.tallyMeasureGroups();
    });

    $('.measure_cb').change(function() {
        $.testWizard.tallyMeasureGroups();
    });

    $('#product_test_patient_population,input[name=download_format]').change(function(){
        $.testWizard.updateDownloadFilename();
    });

    $('[name=population_name]').change(function() {
        $('[name=population_description]').addClass("required");
    });
    $('[name=population_description]').change(function() {
        $('[name=population_name]').addClass("required");
    });

    // for choosing the workflow option
    $('label').hover(function(){
        $(this).parent().addClass('highlight')
    },
    function(){
        $(this).parent().removeClass('highlight')
    }
    ).click(function(){
        var self = this;
        $.each(['wf1','wf2','wf3'], function(i,e) {
            $('.'+e+'_container').removeClass('selectedWorkflow');
        });
        $(this).parent().addClass('selectedWorkflow');
    });

    // for determining the download filename
    $('#wf2').click(function(){
        $('#html,label[for="html"]').hide();
        $('#c32').attr('checked',true);
        $('#c32,#ccr,label[for="c32"],label[for="ccr"]').show();
    });
    $('#wf1').click(function(){
        $('#c32,#ccr,label[for="c32"],label[for="ccr"]').hide();
        $('#html').attr('checked',true);
        $('#html,label[for="html"]').show();
    });
    $('#product_test_patient_population,input[name=download_format]').change(function(){
        $.testWizard.updateDownloadFilename();
    });
    // set the default choice by invoking a click on workflow 2
    $('label[for=wf2]').trigger("click");

    $('#effective_date_end').datepicker({
        onSelect: function(dateText, inst) {
            var effective_date = dateText;
            $.post("/product_tests/period", {
                "effective_date": effective_date,
                "persist": false
            }, function(data){
                $("#effective_date_start").html(data.start);
            },"json");
        }
    }).css({
        'width':'85px',
        'text-align':'center'
    });

    //
    var cache = {}; // caching inputs for the visited steps

    // Variables for the minimal patient set
    var minimalCount = 0;
    var minimalPatients = [];
    var usedOverflow = [];
    var coverage = [];


    $.fx.off = true; // disable the annoying animations the wizard uses
    // for styling the vertical tabs
    $('#tabs').tabs().addClass('ui-tabs-vertical ui-helper-clearfix').css({
        "width":"90%",
        "margin-left":"5%"
    });
    $("#tabs li").removeClass('ui-corner-top').addClass('ui-corner-left');
    $('#tabs').tabs("select",2)
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
                "product_test[effective_date_end]": {
                    required: true,
                    date: true
                },
                "product_test[patient_population]": "required",
                "product_test[measure_ids][]": "required",
                "byod": "required"
            },
            errorClass: "validationErrors",
            messages: {
                "product_test[name]": {
                    required:"The test needs a name."
                },
                "product_test[effective_date_start]": {
                    required:"Specify the start of the reporting period.",
                    date:"Correct date format: mm/dd/yyyy"
                },
                "product_test[effective_date_end]": {
                    required:"Specify the end of the reporting period",
                    date:"Correct date format: mm/dd/yyyy"
                },
                "product_test[patient_population]": {
                    required:"Choose a patient population."
                },
                "product_test[measure_ids][]": {
                    required:"You must choose at least one quality measure."
                },
                "byod": {
                    required:"You must provide a .zip file containing your patient records."
                }
            },
            errorPlacement: function(error, element) {
                error.appendTo( $('#validationErrorMessages') );
            }
        }
    }).bind("step_shown", function(event,data){ //TODO still need to hook up validation
        // do screen-specific functions here
        if (data.currentStep == "wizard-patients-automated-screen") {
            $.testWizard.updateDownloadFilename();
        } else if (data.currentStep == "wizard-patients-manual-screen") {
            $.testWizard.updateMinimalPatientSet();
        }
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

