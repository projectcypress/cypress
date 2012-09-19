$(document).ready(function() {

    // for styling the vertical tabs
    $('#tabs').tabs();
    $("#tabs li").removeClass('ui-corner-top').addClass('ui-corner-left');
    $('#tabs').tabs("select",2)

    $("#measureMap label").click(function() {
        checkbox = $(this).prev('input:checkbox');
        checkbox.prop('checked', !checkbox.prop('checked')).change();
    });

    $("#measureMap input:text").keyup(function() {
        if ($(this).val() === '')
            $(this).closest('dd').find('input:checkbox').prop('checked', false).change();
        else
            $(this).closest('dd').find('input:checkbox').prop('checked', true).change();
    });

    $(".expander").toggle(
        function() {
            $(this).addClass('open');
            var codeElement = $(this).data('code');
            var codes = $("." + codeElement);
            codes.show();
        },
        function() {
            $(this).removeClass('open');
            var codeElement = $(this).data('code');
            var codes = $("." + codeElement);
            codes.hide();
        });

    $('#new_product,.edit_product').validate({
        rules: {
            "product[name]": "required",
            "product[measure_map][]": "required"
        },
        errorClass: "validationErrors",
        messages: {
            "product[name]": {
                required:"The product needs a name."
            },
            "product[measure_map][]": {
                required:"You must choose at least one quality measure.  If you aren't sure how to choose, select them all."
            }
        },
        errorPlacement: function(error, element) {
            error.appendTo( $('#validationErrorMessages') );
        }
    });

    // default to all measures enabled
    toggleMeasures(true);
    
});

// Add functionality to buttons that check or uncheck all Measures by category in the form.
function toggleMeasures(toggleSetting, group) {
    var selector = "#measureMap input:checkbox"
    if (group) {
        selector = '#measureMap input:checkbox.' + group;
    }
    $(selector).prop('checked', toggleSetting).change();
}

function toggleRow(row, toggleSetting) {
    if (toggleSetting)
        row.closest('dd').removeClass('inactive');
    else
        row.closest('dd').addClass('inactive');

    var text = row.find('input:text');
    if (toggleSetting && text.val() === '') {
        text.css('border', '1px red solid');
        text.closest('dd').find('.measure_expander').toggle();
    } else {
        text.css('border', '');
    }
}

function editMappings(category) {
    var selector = "span.mapping input";
    $(selector).prop('readonly', $(selector).prop('readonly') ? false : true);
    $('#editMode').html($('#editMode').html() == "edit" ? "view only" : "edit")
}

function verify() {
    return false;
}

