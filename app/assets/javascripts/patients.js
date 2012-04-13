$(document).ready(function() {
    $(".code_expander").toggle(
        function() {
            $(this).addClass('open');
            var codeElement = $(this).data('code');
            var codes = $("#" + codeElement);
            codes.slideDown(500);
        },
        function() {
            $(this).removeClass('open');
            var codeElement = $(this).data('code');
            var codes = $("#" + codeElement);
            codes.slideUp(500);
        });
});


