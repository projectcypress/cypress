/*************************************************************************
    Namespaced method to use in conjunction with responsive methods.
**************************************************************************/
var A11yResp = {
    Core: function() {
        //Set responsive indicator in body
        var indicator = document.createElement('div');
        indicator.id = 'screen-indicator';
        $('body').prepend(indicator);

        //add browser compatibility
        if ($('meta[http-equiv]').length === 0) {
            $('title').before('<meta http-equiv="X-UA-Compatible" content="IE=edge">');
        }

        //add responsive meta tag to the head
        if ($('meta[name=viewport]').length === 0) {
            $('title').before('<meta name="viewport" content="width=device-width">');
        }

    },
    debounce: function(func, wait, immediate) {
        var timeout;
        return function() {
            var context = this,
                args = arguments;
            var later = function() {
                timeout = null;
                if (!immediate) func.apply(context, args);
            };
            var callNow = immediate && !timeout;
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
            if (callNow) func.apply(context, args);
        };
    },
    getScreenWidth: function() {
        var index;
        //requires media query css reference to #screen-indicator in order to work.
        if (window.getComputedStyle) {
            index = parseInt(window.getComputedStyle(document.getElementById('screen-indicator')).getPropertyValue('z-index'), 10);
        } else {
            // Use .getCompStyle instead of .getComputedStyle
            window.getCompStyle = function(el, pseudo) {
                this.el = el;
                this.getPropertyValue = function(prop) {
                    var re = /(\-([a-z]){1})/g;
                    if (prop == 'float') prop = 'styleFloat';
                    if (re.test(prop)) {
                        prop = prop.replace(re, function() {
                            return arguments[2].toUpperCase();
                        });
                    }
                    return el.currentStyle[prop] ? el.currentStyle[prop] : null;
                };
                return this;
            };
            index = parseInt(window.getCompStyle(document.getElementById('screen-indicator')).getPropertyValue("z-index"), 10);
        }

        var states = {
            2: 'screen-lg-min',
            3: 'screen-md-min',
            4: 'screen-sm-min',
            5: 'screen-xs-min',
            6: 'screen-xs-max',
            7: 'screen-sm-max',
            8: 'screen-md-max'
        };

        return states[index] || 'desktop';
    },
    accordionsToTabs: function() {
        $('.accordions-tabs.ui-accordion').each(function() {
            var $this = $(this);
            var t = 0;
            $this.prepend('<ul></ul>');
            $(this).find("> .ui-accordion-header").each(function() {
                t++;
                $this.find('ul').append('<li><a href="#tabs-' + t + '">' + $(this).text() + "</a></li>");
            });

            $(this).find("> .ui-accordion-header").remove();

            $(this).accordion("destroy");
            $(this).tabs();
        });
    },
    tabsToAccordions: function() {
        $('.accordions-tabs.ui-tabs').each(function() {
            var $this = $(this);
            var n = 0;
            $this.find('> ul > li').each(function() {
                $('<h3>' + $(this).text() + '</h3>').insertBefore($this.find('> .ui-tabs-panel').eq(n));
                n++;
            });

            $this.find('> ul').remove();

            $(this).tabs('destroy');
        });
    },

    // Adding Touch Event on default Android browsers <3.
    // Currently browser does not support overflow: auto or overflow: scroll
    // to implement call touchScroll("divID"); on container div
    isTouchDevice: function() {
        try {
            document.createEvent("TouchEvent");
            return true;
        } catch (e) {
            return false;
        }
    },
    touchScroll: function(id) {
        if (this.isTouchDevice()) { //if touch events exist...
            var el = document.getElementById(id);
            var scrollStartPosY = 0;
            var scrollStartPosX = 0;

            document.getElementById(id).addEventListener("touchstart", function(event) {
                scrollStartPosY = this.scrollTop + event.touches[0].pageY;
                scrollStartPosX = this.scrollLeft + event.touches[0].pageX;
            }, false);

            document.getElementById(id).addEventListener("touchmove", function(event) {
                this.scrollTop = scrollStartPosY - event.touches[0].pageY;
                this.scrollLeft = scrollStartPosX - event.touches[0].pageX;
            }, false);
        }
    }


    //end of A11y Responsive namespace functions
};



/*******************************************
    Extension Methods for jQuery widgets
*******************************************/


//Extends jQuery JPanel library
A11yjPanel = function() {


    // If navlist doesn't exist - use left-navs
    var jPMmenu = document.getElementById('left-navs') === null ? '.nav-main > ul' : '#left-navs > ul';
    var jPMmenuIdentify = document.getElementById('left-navs') === null ? 'jpanel-topnav' : 'jpanel-leftnav';
    var jPM;

    //check if jPanel dependency is loaded.
    if (typeof $.jPanelMenu === 'function') {
        //var jPMmenu = this;
        jPM = $.jPanelMenu({
            menu: jPMmenu, //default '#menu', 
            trigger: 'button.navbar-toggle-main', //default .menu-trigger
            openPosition: '250px',
            keyboardShortcuts: 'false',
            closeOnContentClick: false,
            afterOn: function() {
                $('#jPanelMenu-menu').insertBefore('.jPanelMenu-panel');

                // Remove all classes and and panel-group and nav class for collapse functionality
                $('#jPanelMenu-menu').removeClass().addClass('nav panel-group ' + jPMmenuIdentify);

                // Add class to direct children for collapse functionality
                $('#jPanelMenu-menu > li').addClass('side-menu');

                // Only add the following if and only if the menu contains submenu
                if ($(jPMmenu).find('> li > ul').length > 0) {
                    // Remove jquery ui stuff
                    $('#jPanelMenu-menu li').removeClass('ui-menu-item');
                    $('#jPanelMenu-menu li a').removeAttr('id aria-haspopup').removeClass('ui-corner-all');
                    $('#jPanelMenu-menu .submenu-separator-container, #jPanelMenu-menu .ui-menu-icon').remove();
                    $('#jPanelMenu-menu li ul').removeAttr('style').removeClass('ui-menu ui-widget ui-widget-content ui-corner-all');
                }

                // Make the links expand collapse if the parent menu contains more than 1 link
                if ($(jPMmenu).find('> li ul > li').length > 1) {
                    $('#jPanelMenu-menu > li > a')
                        .wrapInner('<span>')
                        .attr('href', 'javascript:void(0)')
                        .append(function() {
                            return '<em class="glyphicon glyphicon-chevron-down"><span class="sr-only">Click to expand ' + $(this).text() + ' menu</span></em>';
                        });

                    // Add collapsed class for toggling bg of the anchor tag
                    $('#jPanelMenu-menu > li > a').addClass('collapsed');

                    // On upper level link click
                    $('#jPanelMenu-menu > li > a').on('click', function() {
                        // Collapse all open dropdowns
                        $('#jPanelMenu-menu > li > ul.in').collapse('hide');

                        // Toggle the one that is directly under the anchor that is being clicked
                        $(this).next().collapse('toggle');
                    });

                    // Catch collapse events
                    $('#jPanelMenu-menu > li > ul').on({
                        'show.bs.collapse': function() {
                            // Remove class collapsed from the anchor if the dropdown is shown
                            $(this).prev().removeClass('collapsed');
                        },

                        'hide.bs.collapse': function() {
                            // Add class collapsed from the anchor if the dropdown is hidden
                            $(this).prev().addClass('collapsed');
                        }
                    });

                    // Add class to dropdown uls for collapse functionality
                    $('#jPanelMenu-menu > li > ul').addClass('panel-collapse collapse sub-menu');
                } else {
                    // Add class to dropdown uls for collapse functionality
                    $('#jPanelMenu-menu > li > ul').addClass('panel-collapse sub-menu');
                }

            },
            afterOpen: function() {
                $('#liveText-polite').text('Menu has opened');

                setTimeout(function() {
                    if ($('#jPanelMenu-menu').find(':focusable').length > 0) {
                        $('#jPanelMenu-menu').find(':focusable')[0].focus();
                    }
                }, 500);
                
                // Focus
                $('#jPanelMenu-menu').on('keydown', function(e) {
                    // On tab out, focus to the trigger
                    if(e.keyCode == 9) {
                        var skipToggle = false;
                        // For links containing submenu
                        if($('#jPanelMenu-menu > li > ul').length > 0 && ($('#jPanelMenu-menu > li:last-child > a.collapsed').is($(e.target)) || $('#jPanelMenu-menu > li:last-child > ul > li:last-child > a').is($(e.target)))) skipToggle = true;
                        if($('#jPanelMenu-menu > li > ul').length == 0 && $('#jPanelMenu-menu > li:last-child > a').is($(e.target))) skipToggle = true;

                        if(skipToggle) {
                            e.preventDefault();
                            $('#liveText-polite').text('Menu has closed');
                            jPM.close();
                        }
                    }
                });
            },
            afterClose: function() {
                $('button.navbar-toggle-main').focus();
            }
        });
    } else {
        console.log('Missing jPanel library');
    }

    return jPM;
};
//end of extension methods