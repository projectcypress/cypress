!function ($) {
  
  var pluginName = 'navigator',
      defaults = {
        first:'.nav-first', // selector for element to bind to 'first' action
        prev:'.nav-prev', // selector for elements to bind to 'prev' action 
        next:'.nav-next',
        last:'.nav-last',
        targets : 'body',
        nav:'a' // selector for the list of hrefs
      };

  function Navigator(element,options) {
    this.element = element;
    this.$element = $(element);
    this.options = $.extend({},defaults,options);

    this._defaults = defaults;
    this._name = pluginName;
    
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
    console.log(this.targets[0].href);
    var tgt = $(this.targets[0]).attr('href');
    jumpToElement(tgt);
    this.index = 0;
  }
  Navigator.prototype.prev = function() {
    this.index = (this.index + this.targets.length - 1 ) % this.targets.length;
    var tgt = $(this.targets[this.index]).attr('href');
    jumpToElement(tgt);
  }
  Navigator.prototype.next = function() {
    this.index = (this.index + this.targets.length + 1 ) % this.targets.length;
    var tgt = $(this.targets[this.index]).attr('href');
    jumpToElement(tgt);
  }
  Navigator.prototype.last = function() {
    this.index = this.targets.length - 1;
    var tgt = $(this.targets[this.index]).attr('href');
    jumpToElement(tgt);
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
