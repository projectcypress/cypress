$(document).ready(function() {
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
});


