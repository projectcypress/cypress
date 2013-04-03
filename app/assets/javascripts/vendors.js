$(document).ready(function() {
    $(".expander").click(
        function() {
            if ($(this).hasClass('open')) {
                $(this).removeClass('open');
            }
            else {
                $(this).addClass('open')
            }
            var codeElement = $(this).data('code');
            var codes = $("." + codeElement);
            codes.toggle(50);
        });
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


