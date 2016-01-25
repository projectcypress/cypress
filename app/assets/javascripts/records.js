var ready;
ready = function() {
  // instatiate the select2 plugin for the measure filter on the MPL
  $('#measure_id').select2({
    theme: "bootstrap"
  }).on('change', function(e){
    url = $(e.target).val();
    if (url) {
      $.get(url);
    } else {
      $.get('records/by_measure');
    }
  });
}

$(document).ready(ready);
$(document).on('page:load', ready);
