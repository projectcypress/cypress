/*global Turbolinks */

// require turbolinks
// require jquery2
// require jquery_ujs
// require jquery.remotipart
// require parsley/parsley
// require dragon_drop/dragon-drop
// require dataTables/jquery.dataTables
// require jquery-ui/widgets/autocomplete
// require jquery-ui/widgets/tabs
// require jquery-ui/widgets/accordion
// require jquery-ui/widgets/button
// require jquery-ui/widgets/dialog
// require jquery-ui/widgets/menu
// require jquery-ui/widgets/progressbar
// require jquery-ui/widgets/slider
// require jquery-ui/widgets/spinner
// require jquery-ui/widgets/tooltip
// require jquery-ui/widgets/datepicker
// require assets_framework/assets.core
// require assets_framework/breadcrumb
// require jasny-bootstrap.min
// require local-time
// require_tree .
// require popper

// import "turbolinks";
// import "popper";
// import "bootstrap";
// import "jasny-bootstrap";
// import "datatables.net";
// import "datatables.net-dt/css/jquery.dataTables.css";
// will cover turbolinks changes (ajax already covered by rails ujs)
// this is necessary for CSRF tokens in changed form elements
// any statically changed form elements will require a separate token refresh call


import $ from "jquery2";
//import jquery from "jquery2";
//import "parsley";
import * as cypress from "cypress";
// import Turbolinks from "turbolinks";
import * as bootstrap from 'bootstrap';
import "datatables"
// import "jquery-ui/widgets/autocomplete"
import "jquery-ui"
import "jasny-bootstrap";
import "@hotwired/turbo-rails";
import "controllers"
// import "jquery-ui/widgets/accordion"
// import "jquery-ui/widgets/button"
// import "jquery-ui/widgets/dialog"
// import "jquery-ui/widgets/menu"
// import "jquery-ui/widgets/progressbar"
// import "jquery-ui/widgets/slider"
// import "jquery-ui/widgets/spinner"
// import "jquery-ui/widgets/tooltip"
// import "jquery-ui/widgets/datepicker"

// window.$ = $;
// window.jQuery = $;

function popup(id) {
  var popup_element = document.getElementById(id);
  if(popup_element !== null){
    popup_element.classList.toggle("show");
  }
}

document.querySelectorAll('.popup').forEach((button) => {
  button.addEventListener('click', (event) => {
    const buttonId = event.currentTarget.id; // Get the ID of the clicked button
    popup('popuptext-'+buttonId);
  });
});

// $(document).on('page:load', cypress.initializeInfiniteScroll());
// $(document).on('page:change', cypress.updateBundleStatus());

// $(document).on('page:load page:restore page:partial-load', cypress.initializeRecord());

// $(function() {
//   cypress.initializeJqueryCvuRadio();
//   cypress.initializeProductTable();
//   cypress.reticulateSplines();
//   cypress.initializeMeasureSelection();
//   cypress.initializeActionModal();
//   cypress.initializeAdmin();
//   cypress.initializeChecklistTest();
//   cypress.initializeCollapsible();
//   cypress.initializeTestExecution();

//   //$('.breadcrumb').breadcrumb();

//   $(document).on('ajaxComplete',function(e){
//     if(e.delegateTarget.activeElement.tagName.toLowerCase() == 'button') {
//       $(e.delegateTarget.activeElement).blur();
//     }
//   });

//   $(document).on('submit',function(e){
//     window.setTimeout(function(){
//       $(e.delegateTarget.activeElement).blur();
//     }, 1500);
//   });
// });

document.addEventListener("DOMContentLoaded", function() {
  var commentsContainer = document.getElementById("pocs");
  var addCommentButton = document.getElementById("add-poc");
  var uniqueIndex = new Date().getTime();

  addCommentButton.addEventListener("click", function() {
    // Get the template for a new comment
    var newCommentTemplate = document.querySelector("#new-poc-template").innerHTML;

    var newFieldHtml = newCommentTemplate.replace(/new_record/g, uniqueIndex);

    // Insert the new comment fields into the container
    commentsContainer.insertAdjacentHTML("beforeend", newFieldHtml);

    uniqueIndex++;
  });

  commentsContainer.addEventListener("click", function(event) {
    if (event.target.classList.contains("remove-poc")) {
      var nestedFields = event.target.closest(".nested-fields");
      nestedFields.querySelector('input[name*="_destroy"]').value = "1";
      nestedFields.style.display = "none";
    }
  });
});

!function ($) {

  var pluginName = 'navigator',
      defaults = {
        first: '.nav-first', // selector for element to bind to 'first' action
        prev: '.nav-prev',   // selector for elements to bind to 'prev' action
        next: '.nav-next',   // selector for elements to bind to 'next' action
        last: '.nav-last',   // selector for elements to find to 'last' action
        targets : 'body',
        action : function(anchor) {},
        nav: 'a' // selector for the list of hrefs
      };

  function Navigator(element, options) {
    this.element = element;
    this.$element = $(element);
    this.options = $.extend({}, defaults, options);

    this._defaults = defaults;
    this._name = pluginName;
    this.action = this.options.action;
    this.init();

    return this;
  }

  Navigator.prototype.init = function() {
    this.targets = $(this.options.targets);
    this.$_first = this.$element.find(this.options.first);
    this.$_prev = this.$element.find(this.options.prev);
    this.$_next = this.$element.find(this.options.next);
    this.$_last = this.$element.find(this.options.last);
    this.index = 0;
    this.$_first.click($.proxy(this.first, this));
    this.$_prev.click($.proxy(this.prev, this));
    this.$_next.click($.proxy(this.next, this));
    this.$_last.click($.proxy(this.last, this));

  };

  Navigator.prototype.first = function() {
    this.index = 0;
    var tgt = $(this.targets[this.index]).attr('href');
    this.action(tgt);
  }
  Navigator.prototype.prev = function() {
    this.index -= 1;
    if(isNaN(this.index)|| this.index < 0){this.index=0;}
    var tgt = $(this.targets[this.index]).attr('href');
    this.action(tgt);
  }
  Navigator.prototype.next = function() {
    this.index += 1;
    if(isNaN(this.index) || this.index >= this.targets.length) { this.index = this.targets.length - 1;}
    var tgt = $(this.targets[this.index]).attr('href');
    this.action(tgt);
  }
  Navigator.prototype.last = function() {
    this.index =  this.targets.length -1;
    if(isNaN(this.index) || this.index < 0){this.index=0;}
    var tgt = $(this.targets[this.index]).attr('href');
    this.action(tgt);
  }
  Navigator.prototype.setIndex = function(href) {
    for(var i =0; i< this.targets.length; i++){
      if($(this.targets[i]).attr('href') == href){
        this.index = i;
        break;
      }
    }
  }

  $.fn[pluginName] = function(options) {
    return this.each(function() {
      if (!$.data(this,pluginName)) {
        $.data(this,pluginName, new Navigator(this,options));
      }
    });
  }

}(window.jQuery);

(function($) {
  $.fn.fixedHeader = function(options) {
    var config = {
      topOffset: 0
    };
    if (options){ $.extend(config, options); }
    var return_val = this.each(function() {
      var o = $(this);
      var $win = $(window)
        , $head = $('.xml-nav', o)
        , isFixed = 0;

      function processScroll() {
        if (!o.is(':visible')) return;
        var scrollTop = $win.scrollTop();
        var o_top = o.offset().top;
        var head_top = $head.offset().top - config.topOffset;
        if      (scrollTop >= head_top && !isFixed) { isFixed = 1; }
        else if (scrollTop < o_top && isFixed) { isFixed = 0; }

        isFixed ? $head.show().addClass("navbar-fixed-top")
                : $head.removeClass("navbar-fixed-top");
      }
      $win.on('scroll', processScroll);
      processScroll();
    });
    return return_val;
  };

})(jQuery);
import "controllers"
