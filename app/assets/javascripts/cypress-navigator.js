!function ($) {
  
  var pluginName = 'navigator',
      defaults = {
        first:'.nav-first', // selector for element to bind to 'first' action
        prev:'.nav-prev',   // selector for elements to bind to 'prev' action 
        next:'.nav-next',   // selector for elements to bind to 'next' action
        last:'.nav-last',   // selector for elements to find to 'last' action
        targets : 'body',
        action : function(anchor){},
        nav:'a' // selector for the list of hrefs
      };

  function Navigator(element,options) {
    this.element = element;
    this.$element = $(element);
    this.options = $.extend({},defaults,options);

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
    this.$_first.click($.proxy(this.first,this));
    this.$_prev.click($.proxy(this.prev,this));
    this.$_next.click($.proxy(this.next,this));
    this.$_last.click($.proxy(this.last,this));
    
  };



  Navigator.prototype.first = function() {
    this.index = 0;
    var tgt = $(this.targets[this.index]).attr('href');
    this.action(tgt);
  }
  Navigator.prototype.prev = function() {
    this.index = this.index  - 1;
    if(this.index == NaN|| this.index < 0){this.index=0;}
    var tgt = $(this.targets[this.index]).attr('href');
    this.action(tgt);
  }
  Navigator.prototype.next = function() {
    this.index = this.index +1 ;
    if(this.index == NaN || this.index >= this.targets.length){this.index=0;}
    var tgt = $(this.targets[this.index]).attr('href');
    this.action(tgt);
  }
  Navigator.prototype.last = function() {
    this.index =  this.targets.length -1;
    if(this.index == NaN || this.index < 0){this.index=0;}
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
        $.data(this,pluginName,
          new Navigator(this,options));
      }
    });
    
  }
  

}(window.jQuery);


(function($) {
 
$.fn.fixedHeader = function (options) {
 var config = {
   topOffset: 0
 };
 if (options){ $.extend(config, options); }
 
 return this.each( function() {
  var o = $(this);
 
  var $win = $(window)
    , $head = $('.subnav', o)
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
};
 
})(jQuery);