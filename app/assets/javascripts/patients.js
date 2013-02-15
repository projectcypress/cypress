$(document).ready(function() {
    $(".code_expander").mouseenter(
        function() {
            $(this).addClass('open');
            var codeElement = $(this).data('code');
            var codes = $("#" + codeElement);
            codes.slideDown(500);
        });
        $(".code_expander").mouseleave( function() {
            $(this).removeClass('open');
            var codeElement = $(this).data('code');
            var codes = $("#" + codeElement);
            codes.slideUp(500);
        });
});


