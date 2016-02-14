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


  // hacks for accessibility? how to do this after initialization?
  $('.select2-selection').removeAttr('role');
  $('.select2-search__field').attr('aria-label', 'Search measures');
}

$(document).ready(ready);
$(document).on('page:load', ready);
