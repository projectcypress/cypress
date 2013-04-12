$(document).ready(function() {
    // $(".expander").toggle(
    //     function() {
    //         $(this).addClass('open');
    //         var codeElement = $(this).data('code');
    //         var codes = $("." + codeElement);
    //         codes.show();
    //     },
    //     function() {
    //         $(this).removeClass('open');
    //         var codeElement = $(this).data('code');
    //         var codes = $("." + codeElement);
    //         codes.hide();
    //     });
    $('form.new_vendor,form.edit_vendor').validate({
        rules: {
            "vendor[name]": "required"
        },
        errorClass: "validationErrors",
        messages: {
            "vendor[name]": {
                required:"The vendor needs a name."
            }
        },
        errorPlacement: function(error, element) {
            error.appendTo( $('#validationErrorMessages') );
        }
    });

});


