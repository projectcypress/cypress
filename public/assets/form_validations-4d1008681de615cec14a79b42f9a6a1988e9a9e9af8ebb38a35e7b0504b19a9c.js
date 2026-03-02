$(document).on('page:change', function(event) {
  // Since autofocus fires before Parsley/Turbolinks, this fixes
  // Parsley validation on autofocus elements @SS
  $("input[autofocus='autofocus']").focus();
});


$(function() {
  // add custom validation for password field
  window.Parsley
    .addValidator('passwordcomplexity', {
      requirementType: 'regexp',
      validateString: function(value, requirement) {
        var matches = 0;
        [/\d/, /[A-Z]/, /[a-z]/, /[\W]/].forEach(function(pattern){
          if (value.match(pattern)) { matches++ }
        });
        return (matches >= 3);
      },
      messages: {
        en: 'Does not have at least 3 of the specified character types.',
      }
    });

  window.Parsley
    .addValidator('phonenumber', {
      requirementType: 'regexp',
      validateString: function(value, requirement) {
        return value.search(/[A-Za-z]/) == -1;
      },
      messages: {
        en: 'This value may not contain letters.'
      }
    });
});
