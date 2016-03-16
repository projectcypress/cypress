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
      Turbolinks.visit("records");
    }
  });

  // when the user selects a different bundle
  // just take them to the new page
  // use Turbolinks so it doesn't full refresh
  $('.btn-checkbox input[name="[bundle_id]"]').on('change', function() {
    var bundle_id = $(this).val();
    Turbolinks.visit("/bundles/"+bundle_id+"/records");
  });

  // hacks for accessibility? how to do this after initialization?
  $('.select2-selection').removeAttr('role');
  $('.select2-search__field').attr('aria-label', 'Search measures');
}

$(document).ready(ready);
$(document).on('page:load', ready);
