+ function($) {
	'use strict';
	var Breadcrumb = function(element, options) {
		this.options = options;
		this.element = $(element);
		this.window = $(window);
		this.create();
	}

	Breadcrumb.DEFAULTS = {
		leftControlClass: 'glyphicon glyphicon-chevron-left',
		rightControlClass: 'glyphicon glyphicon-chevron-right'
	}

	Breadcrumb.prototype.create = function() {
		// Add wrappers
		this.element.wrap('<div class="breadcrumb-responsive"></div>').wrap('<div class="breadcrumb-container"></div>');

		// Set this.element to responsive div
		this.element = this.element.parents('.breadcrumb-responsive');

		// Add controls
		this.element.prepend('<div class="breadcrumb-left"><a href="javascript:void()"><em class="' + this.options.leftControlClass + '"><span aria-hidden="true" class="adobeBlank">Previous</span></em></a></div>');
		this.element.append('<div class="breadcrumb-right"><a href="javascript:void()"><em class="' + this.options.rightControlClass + '"><span aria-hidden="true" class="adobeBlank">Next</span></em></a></div>');

		// Give the active class, an sr-only text to indicate that it is active
		//this.element.find('li.active a').append('<span class="sr-only"> - you are here</span>');

		// Initial toggle
		this.toggleControls(this);

		var self = this;
		this.window.on('resize', function() {
			self.toggleControls(self);
			self.resetPos(self);
		});

		this.element.find('.breadcrumb-left > a').on('click', function(e) {
			self.navigateLeft();
			e.preventDefault();
		});

		this.element.find('.breadcrumb-right > a').on('click', function(e) {
			self.navigateRight();
			e.preventDefault();
		});

		this.element.find('.breadcrumb > li > a').on('focus', function(e) {
			if ($(this).parent('li').is(':first-child')) {
				self.resetPos(self);
			} else if ($(this).parent('li').is(':last-child')) {
				self.element.find('.breadcrumb-container').scrollLeft(self.breadcrumbWidth() - self.element.outerWidth() + parseInt(self.element.find('.breadcrumb').css('padding-left')) + parseInt(self.element.find('.breadcrumb').css('padding-right')));
			}
			self.toggleControls(self);
		});
	}

	Breadcrumb.prototype.toggleControls = function(self) {
		if (self.breadcrumbWidth() > self.element.outerWidth()) {
			// Show controls && set width
			var controlWidth = 0;
			// Left controller
			if (self.getPos() > 0) {
				self.element.addClass('control-left-visible');
				controlWidth += this.element.find('.breadcrumb-left').outerWidth();
			} else {
				self.element.removeClass('control-left-visible');
			}

			// Right controller
			if (self.getPos() < (self.breadcrumbWidth() - self.element.outerWidth() + parseInt(self.element.find('.breadcrumb').css('padding-left')))) {
				self.element.addClass('control-right-visible');
				controlWidth += this.element.find('.breadcrumb-right').outerWidth();
			} else {
				self.element.removeClass('control-right-visible');
				self.element.find('.breadcrumb-left>a').focus();
			}

			var calculation = self.element.outerWidth() - controlWidth - 1;
			self.element.find('.breadcrumb-container').width(calculation);


		} else {
			self.element.removeClass('control-left-visible');
			self.element.removeClass('control-right-visible');
			self.element.find('.breadcrumb-container').width('auto');
		}
	}

	Breadcrumb.prototype.breadcrumbWidth = function() {
		var width = 0;

		this.element.find('.breadcrumb > li').each(function() {
			width += $(this).outerWidth();
		});

		var padding = parseInt(this.element.find('.breadcrumb').css('padding-left')) + parseInt(this.element.find('.breadcrumb').css('padding-right'));
		var inlineSpace = 4 * (this.element.find('.breadcrumb > li').length - 1);
		return (width + padding + inlineSpace);
	}

	Breadcrumb.prototype.controlsWidth = function() {
		var width = this.element.find('.breadcrumb-left').outerWidth() + this.element.find('.breadcrumb-right').outerWidth();

		return width;
	}

	Breadcrumb.prototype.navigateLeft = function(e) {
		var calculation = (this.getPos() - 50 < 0) ? 0 : this.getPos() - 50;

		if (this.getPos() > 0) {
			this.element.find('.breadcrumb-container').scrollLeft(calculation);
			this.toggleControls(this);
		}
	}

	Breadcrumb.prototype.navigateRight = function() {
		var calculation = (this.getPos() + 50 > this.breadcrumbWidth() - this.element.outerWidth() + parseInt(this.element.find('.breadcrumb').css('padding-right'))) ? (this.breadcrumbWidth() - this.element.outerWidth() + parseInt(this.element.find('.breadcrumb').css('padding-left')) + parseInt(this.element.find('.breadcrumb').css('padding-right'))) : this.getPos() + 50;

		if (this.getPos() < (this.breadcrumbWidth() - this.element.outerWidth() + parseInt(this.element.find('.breadcrumb').css('padding-right')))) {
			this.element.find('.breadcrumb-container').scrollLeft(calculation);
			this.toggleControls(this);
		}
	}

	Breadcrumb.prototype.resetPos = function(self) {
		self.element.find('.breadcrumb-container').scrollLeft(0);
	}

	Breadcrumb.prototype.getPos = function() {
		return parseInt(this.element.find('.breadcrumb-container').scrollLeft());
	}

	$.fn.breadcrumb = function(option, _relatedTarget) {
		return this.each(function() {
			var $this = $(this)
			var data = $this.data('bs.breadcrumb')
			var options = $.extend({}, Breadcrumb.DEFAULTS, $this.data(), typeof option == 'object' && option)

			if (!data) $this.data('bs.breadcrumb', (data = new Breadcrumb(this, options)))
			if (typeof option == 'string') data[option](_relatedTarget)
			else if (options.show) data.show(_relatedTarget)
		})
	};

	$.fn.breadcrumb.Constructor = Breadcrumb
}(jQuery);