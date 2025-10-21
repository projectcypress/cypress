//adding comment to test connection between assets-web and global assets

/*******************************************************************************
   Minimum Dependencies: JQuery, JQueryUI JS/CSS, Bootstrap JS/CSS
********************************************************************************/
var debugON = false;
/*******************************************************************************
    Required assistive technology text, can be abstracted for bi-lingual support
********************************************************************************/
var exitText = '<span class="sr-only"> opens a new tab</span>',
    //insert same span but with visible image on page
    exitTextImage = '<span class="fa fa-external-link fa-spacing"><span class="adobeBlank" aria-hidden="true">New Window icon</span></span><span class="sr-only">This link opens a new window or tab</span>',
    //policy text
    policyText = '<a href="http://www.medicare.gov/sharedresources/shared/pages/external-link-disclaimer.aspx" class="fa fa-external-link non-gov-notice" title="Medicare\' External Link Policy" target="_blank"><span class="adobeBlank">New Window icon</span></a>',
    //use hidden text to note where user is located
    youAreHere = '<span class="hiddenText">You are here</span>',
    //add ARIA attributes to mobile navigation and remove if screen size is adjusted above mobile screen size
    mobileDropdownUl = $('#topNavList').find('.navbar-nav'),
    //variable to find accordion header text
    headerTitle;


/*************************************************************************
    Namespaced method to use in conjunction with jQuery extension methods.
**************************************************************************/
var A11y = {
    Core: function() {
        //add sr only text for links that open in new window
        this.externalWindow();

        //add external policy link
        this.externalPolicy();

        //add proper headings 
        this.headings();

        //add proper font iconts
        this.fontIcons();


        /*******************************************
            find focusable item when page changes
        *******************************************/
        var focusable = $('html').find().first(':focusable');

        /*******************************************
            framebuster
        ********************************************/
        //hide content on page load, can be any element
        $(".container").hide();
        if (window.self === window.top) {
            //show content if not in a frame
            $(".container").show();
        } else {
            //reloads the page to show without frame.
            top.location = self.location;
        }

        /*******************************************
            Live Regions
        ********************************************/
        //add live region for anything to use for announcements to screen readers
        if ($('#liveText').length === 0) {
            $('body').prepend('<div id="liveText" class="sr-only" aria-live="assertive"></div>');
            $('body').prepend('<div id="liveText-polite" class="sr-only" aria-live="polite"></div>');
        }

        /*******************************************
            Mark up presentation tables
        ********************************************/
        // Add attr to presentation tables; for accessibility
        if (!$('.table-presentation').attr('role')) {
            $('.table-presentation').attr('role', 'presentation');
        }

        /*******************************************
            Add global Language if not defined
        ********************************************/
        var htmlAttr = $("html").attr('lang');

        // For some browsers, `attr` is undefined;
        if (typeof htmlAttr === typeof undefined || htmlAttr === false) {
            $('html').attr('lang', 'en-US');
        }

    },
    accordionHelper: function() {
        //toggle accordion header collapsed/expanded status
        $('.ui-accordion-header').find('.sr-section-alert').text(function() {
            return ($(this).parent().hasClass('ui-accordion-header-active')) ? $(this).text().replace('collapsed', 'expanded') : $(this).text().replace('expanded', 'collapsed');
        });
        //toggle accordion header collapsed/expanded icon status
        $('.ui-accordion-header').find('.arrow-icon').text(function() {
            return ($(this).parent().hasClass('fa-caret-down')) ? $(this).text().replace('Collapsed', 'Expanded') : $(this).text().replace('Expanded', 'Collapsed');
        });

    },
    //accordion 508
    accordion: function(el) {

        el.on("accordioncreate", function() {
            //change aria live to active header on selection --- added keyup for spacebar functionality 
            $('.ui-accordion-header').removeAttr("aria-live").next('div').removeAttr('aria-live').attr('aria-expanded', 'false');
            $('.ui-accordion-header').find('.ui-accordion-header-icon').attr({
                'role': 'presentation',
                'aria-hidden': true
            });
            $('.ui-accordion-header-active').next('div').attr('aria-live', 'polite');

            $('.ui-accordion-header').append('<span class="sr-only sr-section-alert"> section is collapsed</span>').children('.ui-accordion-header-icon');
            if ($('html').hasClass('ui-helper-nocustomfonts') && ($('html').hasClass('lt-ie9') || $('html').hasClass('ie9') || $('html').hasClass('ie10') || $('html').hasClass('ie11'))) {
                $('.ui-accordion-header').append('<span class="sr-only sr-section-alert"> section is collapsed</span>').children('.ui-accordion-header-icon').html('<span class="adobeBlank arrow-icon" aria-hidden="true">Collapsed arrow icon</span>');
            }
            A11y.accordionHelper();

        });
        el.on("accordionbeforeactivate", function(event) {
            //make changes before new tab is opened so screen reader announces the changes
            var activeHeader = $(event.target).attr('id');

            $('.ui-accordion-header').find('.sr-section-alert').text(function() {
                return (activeHeader) ? $(this).text().replace('collapsed', 'expanded') : $(this).text().replace('expanded', 'collapsed');
            });


        });
        //change Expand collapse due to collapsible bug with aria expanded
        el.on("accordionactivate", function() {
            var activeContent = $(this).find('.ui-accordion-content-active');
            $(this).children().each(function() {
                A11y.accordionHelper();
            });
            $('.ui-accordion').find('.ui-accordion-header-active').attr({
                'aria-expanded': true,
                'aria-selected': true
            });
            //activeContent.focus();
        });
    },

    //alert 508
    alerts: function() {
        //Close alert and return focus to last focused element
        $("body").on("click", ".close", function() {
            $(this).blur();
            $(this).closest(".alert").fadeOut("slow");
            $(this).parent().prev().focus();
            $(this).closest(".alert").delay(1500).remove();
        });
    },

    //autocomplete 508
    autocomplete: function() {
        //add a half second delay to when autocomplete suggestion shows for screen reader
        $(".ui-autocomplete-input").attr("aria-controls", "list").attr("aria-haspopup", "true");

        /*$(".ui-autocomplete-input").on("click", function(){
             $('html,body').animate({
                scrollTop: $(this).offset().top
            }, 1000);
        });*/

        $(".ui-autocomplete-input").on("autocompleteselect", function(event, ui) {
            $('#liveText').html(ui.item ? 'Selected: ' + ui.item.value : 'Nothing selected');
        });

    },
    bindSkipNav: function(e) {
        e.preventDefault();
        var target = $(e.target).attr('href');
        $(target).focus();
    },

    //block UI 508
    block: function(el, enable) {
        //adding structure for jquery ui dialog
        if ($(".blockUI")) {
            if (enable) {
                $('.wrapper').attr('aria-hidden', 'true');
                $('#liveText').html('Processing Started. Please wait');

                setTimeout(function() {
                    $(".blockUI").attr({
                        tabindex: "-1",
                        width: "auto"
                    });
                }, 10); //set tabindex to -1 after title receives focus
            } else {
                $('.wrapper').attr('aria-hidden', 'false');
                $('#liveText').html('Processing Completed');
            }

        }

    },

    // Custom input
    customInput: function() {
        $('input[type=checkbox], input[type=radio]').each(function() {
            var input = $(this);

            // get the associated label using the input's id
            var label = $('label[for=' + input.attr('id') + ']');


            // add disabled class for disabled inputs
            if (input.attr('disabled')) label.addClass('disabled');
        });
    },

    carousel: function() {
        //show-hide prev/next buttons and change focus for when each is hidden
        $('#myCarousel').carousel({
            interval: false,
            wrap: false
        }).on('slid.bs.carousel', function() {
            var pages = $(this).find("ul.item");
            var currentPage = pages.filter(".active");
            var currentIndex = pages.index(currentPage) + 1;
            var lrUpdate = "Showing Carousel page " + currentIndex + " of " + pages.length;
            $(".myCarousel-liveRegion").text(lrUpdate);

            var $this = $(this);
            $this.children('.carousel-control').show();
            if ($('.carousel-inner .item:first').hasClass('active')) {
                $this.children('.left.carousel-control').hide();
                //focus on first li a of first ul in carousel when the prev navigation button is hidden
                $('.carousel-inner .item:first').find('li:first>a').focus();

            } else if ($('.carousel-inner .item:last').hasClass('active')) {
                $this.children('.right.carousel-control').hide();
                //focus on last li a of last ul in carousel when the next navigation button is hidden
                $('.carousel-inner .item:last').find('li:last>a').focus();
            }
        });
        $('.left.carousel-control').hide();
        $('.right.carousel-control').show();
    },

    //datatables 508
    datatables: function() {

        //for datatables, add first and second columns into sr only description of row edit/remove buttons
        /*$('.rowActionBtn').each(function(index, element) {
            var firstColumn = $(this).closest('tr').children(':first-child').text().trim();
            var lastColumn = $(this).closest('tr').children(':nth-child(2)').text().trim();
            $(this).children(".actionRowNum").html(firstColumn + ' ' + lastColumn);
            $('.paginate_enabled_previous, .paginate_enabled_next').css('cursor', 'pointer');
         });*/
        $('.previous, .next').on('click', function() {
            $('.rowActionBtn').each(function(index, element) {
                var firstColumn = $(this).closest('tr').children(':first-child').text().trim();
                var lastColumn = $(this).closest('tr').children(':nth-child(2)').text().trim();
                $(this).children(".actionRowNum").html(firstColumn + ' ' + lastColumn);
            });

        });
        //copy abbr from li and place on child anchor for screen reader
        $(".dataTable th").each(function(index, element) {
            $(this).attr('aria-label', $(this).attr('abbr'));
        });
        //data tables remove action link in header and replace with P tag
        if ($(".dataTable th").hasClass('sorting_disabled')) {
            //data tables remove action link in header and replace with P tag
            var alertItem = $('.sorting_disabled').children('a').text();
            $(".sorting_disabled").children("a").delay(100).replaceWith("<p class='fauxLinkHeader'>" + alertItem + "</p>");
            $(".fauxLinkHeader").css({
                'font-size': '1em',
                'line-height': '1.125em',
                'margin-bottom': '0',
                'text-decoration': 'underline',
                'cursor': 'context-menu'
            });
        }
        $(".fa-trash-o").attr("style", "font-family :'FontAwesome' !important").html("<span class='adobeBlank'>Delete icon </span>");
        //change text for save button also
        $('.dataTable').on('click', '.rowActionBtn.save', function() {
            $('#liveText').text('Changes Saved');
            setTimeout(function() {
                $('#liveText').text('');
            }, 1000);
            $(this).closest('tr').find('.edit').focus();
        });
        $('.dataTable').on('click', '.rowActionBtn.edit', function() {
            var firstColumn = $(this).closest('tr').children(':first-child').find('input').val();
            var lastColumn = $(this).closest('tr').children(':nth-child(2)').find('input').val();
            if (debugON) console.log(firstColumn);
            $(this).children(".actionRowNum").text(firstColumn + ' ' + lastColumn);

            $('#liveText').text('Editing ' + firstColumn + ' ' + lastColumn);
            setTimeout(function() {
                $('#liveText').text('');
            }, 1000);
            // wait 1 second to remove message to existing live region
        });
        $('.dataTable').on('click', '.rowActionBtn.delete', function() {
            var firstColumn = $(this).closest('tr').children(':first-child').find('input').val();
            var lastColumn = $(this).closest('tr').children(':nth-child(2)').find('input').val();
            if (debugON) console.log(firstColumn);
            $(this).children(".actionRowNum").text(firstColumn + ' ' + lastColumn);

            $('#liveText').text('Deleted row');
            setTimeout(function() {
                $('#liveText').text('');
            }, 10000);
            // wait 1 second to remove message to existing live region
        });
        //remove links which are disabled from tab order 
        $('.dataTables_paginate a').each(function() {
            if ($(this).hasClass('disabled')) {
                $(this).attr('tabindex', '-1');
            }
        });
        //change tab index on pagination links to remove disabled links from tab order
        $(document).on('click keyup', 'a', function(e) {
            if (e.type == 'click' || (e.type == 'keyup' && e.keyCode == 13)) {
                var dts = $('.dataTables_paginate');
                if ($(dts).hasClass('dataTables_paginate')) {
                    setTimeout(function() {
                        $('.dataTables_paginate a').attr('tabindex', '0');
                        $('.dataTables_paginate a.disabled').attr('tabindex', '-1');
                    }, 100);
                }
            }
        });

    },

    //datepicker 508
    datepicker: function() {
        //add fontawesome font family to datepicker calendars
        $('.date-picker-control .fa.fa-calendar').attr("style", "font-family :'FontAwesome' !important");
    },

    //dialog 508
    dialog: function(el) {
        var dialog = $('.ui-dialog'),
            contents = $('.dialog-contents'),
            titleBar = $('.ui-dialog-titlebar');

        //adding structure for jquery ui dialog
        if ($('div').hasClass('ui-dialog')) {
            dialog.find('.ui-dialog-content').attr('aria-hidden', 'false');
            //wrap dialog inner elements
            if (dialog.find(contents).length === 0) {
                dialog.wrapInner("<div class='dialog-contents' role='document'></div>");
            }
            //add attributes to close button
            titleBar.find('.ui-button').attr({
                    //'tabindex': "0",
                    "aria-label": 'Close'
                }).addClass("fa fa-times-circle icon_circle_remove pull-right")
                .removeClass("ui-dialog-titlebar-close ui-button-icon-only")
                .find('.ui-button-text')
                .addClass("adobeBlank")
                .attr('aria-hidden', 'true')
                .css('position', 'absolute');
            //make title element focusable and set up as H1 
            titleBar.find('.ui-dialog-title').attr({
                'tabindex': '-1',
                'style': 'width: auto',
                'role': 'heading',
                'aria-level': '1'
            })

        }
        if ($("#progressDialog").is('.ui-dialog-content')) {
            if ($('#progressbarText').length === 0) {
                $('.ui-dialog-content').append('<div id="progressbarText" class="sr-only" role="status" aria-live="assertive"></div>');
            }
        };
    },
    dialogOpen: function() {
        var titleBar = $('.ui-dialog-titlebar'),
            title = $('.ui-dialog-title'),
            progressTrigger = $('.progressTriggerFocus');

        //make 'x' close button in header larger
        titleBar.find('.ui-button').attr({
            "style": "font-family: 'FontAwesome' !important;font-size: 44px !important;"
        });
        //change title to H1
        title.replaceWith(function() {
            var attrs = '';
            $($(this)[0].attributes).each(function(i, v) {
                attrs += ' ' + this.nodeName + '="' + this.value + '"';
            });
            return '<h1 ' + attrs + '>' + $(this).text() + '</h1>';
        });



        if ($("#progressDialog").is('.ui-dialog-content')) {
            //If displayed in a modal pop-up remove close button
            setTimeout(function() {
                $(".ui-dialog-titlebar>button").remove();
            }, 2);
            $(document).on("progressbarcomplete", function(event, ui) {
                setTimeout(function() {
                    $('#liveText-polite').text('Progress bar has closed');
                    setTimeout(function() {
                        progressTrigger.attr('aria-hidden', 'false').focus();
                    }, 2000);
                }, 1);
                $(".ui-dialog").remove();
                $('.ui-widget-overlay').remove();
            });

        }
    },
    dialogFocus: function() {
        var title = $('.ui-dialog-title'),
            dialog = $('.ui-dialog'),
            progressbar = $('[role="progressbar"]');
        //focus on h1 after 100th of a second
        setTimeout(function() {
            if (dialog.hasClass('progressBar')) {
                progressbar.focus();
            } else {
                title.focus();
            }
            /*else if ($('html').is('.lt-ie9, .ie9, .ie10, .ie11')) {
                //move focus to H1 tag in IE browsers for JAWS users
                title.focus();
            }*/
        }, 1);
        $('.ui-resizable-handle, .ui-progressbar-overlay').attr('aria-hidden', 'true');
    },
    expandCollapse: function(options) {

        if (options['text'] === true) {


            //change icon hc mode text to toggle on click
            $('.collapsibleBoxActive').on('click', function() {
                if ($(this).children('a').hasClass('collapsible-heading-collapsed')) {
                    $(this).find('.adobeBlank').text('Collapsed Icon');
                } else {
                    $(this).find('.adobeBlank').text('Expanded Icon');
                }
            });

            //change icon hc mode text to toggle on click
            $('.collapsible-heading').on('click', function() {
                if ($(this).hasClass('collapsible-heading-collapsed')) {
                    $(this).find('.adobeBlank').text('Collapsed Icon');
                } else {
                    $(this).find('.adobeBlank').text('Expanded Icon');
                }
            });

        } else {


            if ($(".toggleIcon").hasClass("glyphicon-expand")) {
                $(".toggleIcon").html("<span class='adobeBlank'>Collapsed icon</span>");
            } else if ($(".toggleIcon").hasClass("glyphicon-collapse-down")) {
                $(".toggleIcon").html("<span class='adobeBlank'>Expanded icon</span>");
            }

            $('.toggleIcon').keydown(function(event) {
                if (event.keyCode === 32) {
                    //alert('spacebar');
                    event.preventDefault();
                    $(this).click();
                }
                return true;
            });

            if (options['expandDefault'] === true) {

                $('.collapsible-heading-toggle-icon').attr('aria-expanded', 'true');
                if (!$('.collapsible-heading-toggle-icon').children().hasClass('expand-icon')) {
                    $('.collapsible-heading-toggle-icon').prepend("<em data-collapse-text='collapse' data-expand-text='expand' title='Expanded' class='expand-icon'></em>");
                }
                this.expandIconButton();
            } else {
                $('.collapsible-heading-toggle-icon').attr('aria-expanded', 'false');
                if (!$('.collapsible-heading-toggle-icon').children().hasClass('expand-icon')) {
                    $('.collapsible-heading-toggle-icon').prepend("<em data-collapse-text='collapse' data-expand-text='expand' title='Collapsed' class='collapse-icon'></em>");
                }
                this.expandIconButton();
            }

            //change icon hc mode text to toggle on click
            $('.collapsible-heading-toggle-icon').on('click', function() {
                var icon = $(this).children()[0];

                if (icon !== typeof undefined && icon !== '') {
                    if ($(icon).hasClass('collapse-icon')) {
                        $(icon).parent().attr('aria-expanded', 'true');
                        $(icon).attr('title', 'Expanded').attr('class', 'expand-icon').empty();
                    } else {
                        $(icon).parent().attr('aria-expanded', 'false');
                        $(icon).attr('title', 'Collapsed').attr('class', 'collapse-icon').empty();
                    }
                }

            });

            $('.collapsible-heading-toggle-icon').keydown(function(event) {
                if (event.keyCode === 32) {
                    //alert('spacebar');
                    event.preventDefault();
                    $(this).click();
                }
                return true;
            });

        }
        //removed button role from collapsible image links on expand/collapse
        $(".collapsible-heading").removeAttr("role");
    },

    //create buttons from anchor tags to keep semantics and prevent 'visited link' announcements with screen readers
    expandIconButton: function() {
        //get anchor tag inside of heading tag with 'collapsibleIcon' class
        var anchors = $('.collapsibleIcon > a');
        //if anchor tag exists change it to a button
        if (anchors.length !== 0) {
            var anchorClass = anchors.attr('class'),
                anchorExpanded = anchors.attr('aria-expanded');
            anchors.find('em').attr("style", "font-family :'FontAwesome' !important");
            anchors.wrapInner('<button/>');
            anchors.children('button').attr({
                'class': anchorClass,
                'aria-expanded': anchorExpanded
            }).addClass('btn-link').attr('tabindex', '0');
            anchors.contents().unwrap();
        }
    },

    externalWindow: function() {
        //check if exit text is set otherwise append it.
        $('a[target="_blank"]:not(.sr-set)').append(exitText).addClass('sr-set');
    },

    externalWindowImage: function() {
        //check if exit text is set otherwise append it.
        $('a[target="_blank"]:not(.sr-set)').append(exitTextImage).addClass('sr-set');
    },


    externalPolicy: function() {
        //check if exit text is set otherwise append it.
        if (!$('a.extlink').next().is('a')) {
            $('a.extlink').after(policyText);
        }
    },

    //font based icons 508
    fontIcons: function() {
        $('.fa').attr("style", "font-family :'FontAwesome' !important");
        $('.glyphicon').delay(500).attr("style", "font-family :'Glyphicons Halflings' !important");
        $('button[data-validationtrigger]').on('click', function() {
            $('.fa').attr("style", "font-family :'FontAwesome' !important");
            $('.glyphicon').delay(500).attr("style", "font-family :'Glyphicons Halflings' !important");
        });
    },

    //Set custom focus
    focusMethod: function(options) {
        //Options <delay> <boolean> required, <id> <string> of focuasable element, or <class> <string> of focusable element, or <element> <string> of element name.
        if (options.length !== 0) {
            if (options.delay) {
                //Delay often used to set focus in legacy IE with strict render order
                if (options.id !== undefined) {
                    setTimeout(function() {
                        $('#' + options.id).focus();
                    }, 100);
                } else if (options['class'] !== undefined) {
                    setTimeout(function() {
                        $('.' + options['class']).focus();
                    }, 100);
                } else if (options['element'] !== undefined) {
                    setTimeout(function() {
                        $(options['element']).focus();
                    }, 100);
                }
            } else {
                if (options.id !== undefined) {
                    $('#' + options.id).focus();
                } else if (options['class'] !== undefined) {
                    $('.' + options['class']).focus();
                } else if (options['element'] !== undefined) {
                    $(options['element']).focus();
                }
            }

        }
    },

    //Set custom focus to heading
    focustoHeading: function() {

        var skipto = $("h1:first");

        $(document).scrollTop(skipto.offset().top);
        skipto.attr("tabIndex", "-1");
        skipto.focus();
        skipto.focusout(function() {
            $(this).removeAttr("tabindex");
        });
    },


    // Method to get focused element
    getFocusedElement: function() {
        var elem = document.activeElement;
        return $(elem && (elem.type || elem.href) ? elem : []);
    },

    // Method to get parameters from the querystring
    getQueryStringVal: function(name) {
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS = "[\\?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(window.location.search);
        if (results === null)
            return "";
        else
            return decodeURIComponent(results[1].replace(/\+/g, " "));
    },

    //Method to pull entire querystring
    getQueryString: function(name, uri) {
        if (typeof(uri) != 'string') uri = window.location.href;
        name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
        var regexS = "[\\#?&]" + name + "=([^&#]*)";
        var regex = new RegExp(regexS);
        var results = regex.exec(uri);
        try {
            return results[1];
        } catch (e) {
            return "undefined";
        }
    },

    //Adding aria-level and role for all headings
    headings: function() {
        var headings = "h1, h2, h3, h4, h5, h6";

        $(headings).delay(1000).each(function() {
            if (!$(this).attr('role')) {
                var headingLevel = $(this)[0].nodeName.substring(1);
                $(this).attr({
                    'role': 'heading',
                    'aria-level': headingLevel
                });
            }
        });
    },
    ieDetect: function() {
        //detect ie10/11 and add corresponding class on the HTML element
        var html = $('html'),
            ie10 = (navigator.userAgent.match(/MSIE 10/i)),
            ie11 = !!navigator.userAgent.match(/Trident.*rv[ :]*11\./);
        if (ie10 == "MSIE 10") html.addClass('ie10');
        if (ie11 == true) html.addClass('ie11');
    },
    //allow links that appear as buttons to fucntion with the spacebar
    keyPressLinks: function() {
        $('a[role=button]').off("keypress").on("keypress", function(e) {
            if (e.keyCode === 32) {
                $(this).trigger("click");
                e.preventDefault();
            }
        });
    },

    menu: function(el) {
        //Adding aria-selected for each selected li in menu
        el.on("menufocus", function(event, ui) {
            $(".ui-state-focus").attr('aria-selected', 'true');
        });

        el.on("menublur", function(event, ui) {
            $('.ui-menu a').each(function(index, element) {
                $(this).removeAttr('aria-selected');
            });
        });
    },

    progressbar: function() {
        var progressTrigger = $('.progressTriggerFocus'),
            titleBar = $('.ui-dialog-titlebar');

        $(document).on("progressbarcreate", ".ui-progressbar", function(event, ui) {
            //titleBar.focus();
            $(".ui-progressbar").removeClass("ui-corner-all");
            progressTrigger.attr('aria-hidden', 'true');
            //remove corners class from title bar 
            $(".ui-progressbar-value").removeClass("ui-progressbar-value ui-widget-header ui-corner-left").addClass("ui-progressbar-overlay");

            //Change dialog container to use role='dialog' to read correctly with screen readers
            $('.dialog-contents').attr('role', 'dialog');
        });
    },

    required: function() {
        // Add aria-required="true" and aria-described by to form feilds only
        if ($('span.requiredField').length > 0) {
            var x = 0;
            $('span.requiredField').parent().each(function(index, elem) {
                //add ID to formatting span
                $(this).siblings(".text-tip").attr('id', 'formatting' + x);

                if ($(this).next().prop('type') === 'text' || $(this).next().prop('type') === 'select-one') {
                    $(this).next().attr('aria-required', 'true');
                    $(this).next().attr('aria-describedby', 'formatting' + x);
                } else if ($(this).next().next().prop('type') === 'text' || $(this).next().next().prop('type') === 'select-one') {
                    $(this).next().next().attr('aria-required', 'true');
                    $(this).next().attr('aria-describedby', 'formatting' + x);
                }
                x++;
            });
        }

    },



    //tabs 508
    tabs: function(el) {
        //all changes in the extend for ui.tabs
    },
    //get title of page on view change and add to live region
    titlePageChange: function() {
        var pageTitle = $(document).find("title").text();
        $('#liveText').text(pageTitle);

    },
    //tooltip 508
    tooltips: function() {
        $(".selector").on("tooltipopen", function(event, ui) {});
    }

    //end of A11y namespace function
};



/*******************************************
    Extension Methods for jQuery widgets
*******************************************/

//extend jQuery Accordion widget
$.widget('ui.accordion', $.ui.accordion, {
    _create: function() {
        if (debugON) console.log('Custom Accordion Widget');
        A11y.accordion(this.element);
        return this._super();
    }
});


//extend the autocomplete widget
$.widget("ui.autocomplete", $.ui.autocomplete, {
    _renderItem: function(ul, item) {
        var term = this.element.val(),
            html = item.label;
        return $("<li></li>")
            .append($("<a></a>").html(html))
            .appendTo(ul);
    },
    //508 default instantioantion methods
    delay: 600,
    autoFocus: true,
    mutliple: false,
    _create: function(event, ui) {
        //call 508 helper method
        if (debugON) console.log('Custom Autocomplete Widget');
        A11y.autocomplete();
        return this._super();
    }
});


//extend the jQuery button widget
$.widget("A11y.button", $.ui.button, {
    _create: function() {
        if (debugON) console.log('Custom Button Widget');
        this.element.attr('aria-pressed', 'false')
            .click(function(event) {
                if (event.target !== undefined) {
                    if ($(event.target).is("span"))
                    //mark parent link or input if using span inside button
                        $(event.target).parent().attr('aria-pressed', 'true');
                    else
                        $(event.target).attr('aria-pressed', 'true');
                }
            });
        return this._super();
    }
});

//extend the jQuery dialog widget
$.widget("ui.dialog", $.ui.dialog, {
    //default 508 options
    autoOpen: false,
    resizable: false,
    draggable: false,
    width: 'auto',
    height: 'auto',
    modal: true,
    _title: function(title) {
        A11y.dialog();
        return this._super(title)
    },
    _createOverlay: function() {
        //this loads when dialog is opened
        var bodyTag = $('body > *');
        A11y.dialogOpen();
        /* add focus to h1 tag after delay to allow complete dialog to set up and add aria hidden 
           to each direct descendent of the body tag to prevent screen reader from reading content 
        */
        this._delay(function() {
            A11y.dialogFocus();
            bodyTag.attr('aria-hidden', 'true');
            this.uiDialog.removeAttr('aria-hidden');
        });
        return this._super();
    },
    _createWrapper: function() {
        //remove aria-describedby from dialog
        this._delay(function() {
            var lowerButtonContainer = this.uiDialog.children('.ui-dialog-buttonpane'),
                titleH1 = this.uiDialog.find('.ui-dialog-title').attr('id'),
                dialogContents = this.uiDialog.find('.dialog-contents'),
                innerContents = this.uiDialog.find('.ui-dialog-content'),
                lowerButtonContainerButton = lowerButtonContainer.find('button'),
                headingClosingButton = dialogContents.find('.ui-dialog-titlebar button');

            dialogContents.attr('id', titleH1 + '-contents');
            lowerButtonContainerButton.removeAttr('aria-pressed');
            headingClosingButton.removeAttr('aria-pressed aria-disabled title').find('.ui-icon-closethick').remove();
            var describedById = dialogContents.attr('id');
            //this.uiDialog.removeAttr('aria-describedby');
            //adding label and hiding aria-hidden to text for screen readers to ignore
            $(lowerButtonContainerButton).each(function() {
                var button = $(this),
                    lowerButtonContainerButtonLabel = button.children('.ui-button-text').text().toLowerCase();
                button.removeAttr('aria-pressed').attr('aria-label', lowerButtonContainerButtonLabel).find('.ui-button-text').attr('aria-hidden', 'true');

            });
            this.uiDialog.attr('aria-describedby', describedById);
            if (lowerButtonContainer.length) {
                lowerButtonContainer.find('button').removeAttr('aria-disabled');
                lowerButtonContainer.detach().appendTo('div[role="document"]');
                dialogContents.prepend("<p class='sr-only ui-dialog-hint'>Start of Dialog</p>").append("<p class='sr-only ui-dialog-hint'>End of Dialog</p>");
            }

        });

        return this._super();
    },

    _destroyOverlay: function() {
        //unhide page content for screen readers and hide dialog when closed
        var bodyTag = $('body > *');
        bodyTag.removeAttr('aria-hidden');
        this.uiDialog.attr('aria-hidden', 'true');

        return this._super();
    }
});


//extend the jQuery menu widget
$.widget("ui.menu", $.ui.menu, {
    _create: function() {
        if (debugON) console.log('Custom Menu Widget');
        A11y.menu(this.element);
        return this._super();
    }
});

//extend the jQuery progressbar widget
$.widget("ui.progressbar", $.ui.progressbar, {
    _create: function() {
        if (debugON) console.log('Custom Progressbar Widget');
        A11y.progressbar();
        return this._super();
    },
    _refreshValue: function(value) {
        //adding live region update for safari only
        var is_chrome = navigator.userAgent.indexOf('Chrome') > -1,
            is_safari = navigator.userAgent.indexOf("Safari") > -1,
            progressbarCurValue = $('.ProgressBarContainer').attr('aria-valuenow'),
            progressbarLiveRegion = $('#progressbarText');
        if ((is_chrome) && (is_safari)) {
            is_safari = false;
        }
        if (is_safari) {
            progressbarLiveRegion.text(progressbarCurValue + "%");
        };
        if (value === this.options.max) {
            this._trigger("Progress bar has closed");
        }
        return this._super();
    }
});

//extend the button function
$.widget("ui.slider", $.ui.slider, {
    _refreshValue: function() {
        var val = this.element.slider("value"),
            handle = this.element.children('.ui-slider-handle'),
            option = this.options,
            currentSliderValue = option.value,
            minSliderValue = option.min,
            maxSliderValue = option.max,
            ariaSliderLabel = option.ariaLabel,
            ariaSliderValueText = (option.slideTextValue) ? val + option.slideTextValue : val,
            ariaOrientationValue = (option.ariaOrientation) ? option.ariaOrientation : "";
        handle.attr({
            'aria-valuenow': val,
            'aria-valuetext': ariaSliderValueText,
            'role': 'slider',
            'aria-orientation': ariaOrientationValue,
            'aria-valuemin': minSliderValue,
            'aria-valuemax': maxSliderValue,
            'aria-label': ariaSliderLabel
        });
        return this._super();
    }
});

//extend the spinner function
$.widget("ui.spinner", $.ui.spinner, {
    _create: function() {
        if (debugON) console.log('Custom Spinner Widget');
        //By default the spinner widget is already compliant use this method if it needs future implementatations
        return this._super();
    }
});

//extend the tabs function ++33
$.widget("ui.tabs", $.ui.tabs, {
    _create: function(event, ui) {
        if (debugON) console.log('Custom Tabs Widget');
        //applying the live regiions for page load because the A11y.Core function is not called at time of execution of the tabs widget
        $('body').prepend('<div id="liveText" class="sr-only" aria-live="assertive"></div>');
        $('body').prepend('<div id="liveText-polite" class="sr-only" aria-live="polite"></div>');
        return this._super();
    },
    _refresh: function() {

        //remove specific classes on tabs widget on page load
        var tabContainer = this.element;
        tabContainer.removeClass('ui-widget ui-widget-content ui-corner-all');
        //get the text of the tab that is active on page load 
        if (this.active.length) {
            var newTabText = $.trim(this.active[0].textContent);
            //alert sr via polite live region of tab change
            $('#liveText-polite').text(newTabText + ' tab is selected');
            setTimeout(function() {
                $('#liveText-polite').text('')
            }, 1000)
        } else {}
        return this._super();
    },
    // handles show/hide for selecting tabs
    _toggle: function(event, eventData) {
        //get text of activated tab 
        var newTabText = $.trim(eventData.newTab[0].textContent);
        //alert sr via polite live region of tab change
        $('#liveText-polite').text(newTabText + ' tab is selected');
        setTimeout(function() {
            $('#liveText-polite').text('')
        }, 1000)
        return this._super(event, eventData);
    }
});

//extend jQuery Tooltip widget to separate JQuery UI tooltip from Bootstrap's tooltip
$.widget('A11y.tooltip', $.ui.tooltip, {
    _create: function() {
        return this._super();
    }
});


//extends fillament Group expand widget
$.fn.A11ycollapsible = function(options) {
    //dependency on lang attribute being set on html tag
    if (options === null || options === undefined) {
        //default 508 options
        options = {
            'text': true,
            'icon': false,
            'closeAll': false
        };
    }

    //check if collapsible dependency is loaded.
    if (typeof $.fn.collapsible === 'function') {
        if (debugON) console.log('Custom collapsible Widget');
        $.fn.collapsible.call(this, options);
        A11y.expandCollapse(options);
    } else {
        if (debugON) console.log('Missing jQuery Collapsible library');
    }
};

$.fn.A11ycustomInput = function() {
    if (typeof $.fn.carousel === 'function') {
        $.fn.customInput.call(this);
        A11y.customInput();
    }

};



//extends whatsock acciesability controls date widget
$.fn.A11yblockUI = function() {
    //check if calendar dependency is loaded.
    if (typeof $.fn.block === 'function') {
        if (debugON) console.log('Custom Block UI Start');
        $.blockUI();
        A11y.block($(this), true);

    } else {
        if (debugON) console.log('Missing Jquery Block UI');
    }
};


//extends whatsock acciesability controls date widget
$.fn.A11yUnblockUI = function() {
    //check if calendar dependency is loaded.
    if (typeof $.fn.unblock === 'function') {
        if (debugON) console.log('Custom Block UI Complete');
        $.unblockUI();
        A11y.block($(this), false);

    } else {
        if (debugON) console.log('Missing Jquery Block UI');
    }
};

/* jquery ui datepicker extends */
$.datepicker._showDatepicker = function(input) {
    input = input.target || input;
    if (input.nodeName.toLowerCase() !== "input") { // find from button/image trigger
        input = $("input", input.parentNode)[0];
    }

    if ($.datepicker._isDisabledDatepicker(input) || $.datepicker._lastInput === input) { // already here
        return;
    }

    var inst, beforeShow, beforeShowSettings, isFixed,
        offset, showAnim, duration;

    inst = $.datepicker._getInst(input);
    if ($.datepicker._curInst && $.datepicker._curInst !== inst) {
        $.datepicker._curInst.dpDiv.stop(true, true);
        if (inst && $.datepicker._datepickerShowing) {
            $.datepicker._hideDatepicker($.datepicker._curInst.input[0]);
        }
    }

    beforeShow = $.datepicker._get(inst, "beforeShow");
    beforeShowSettings = beforeShow ? beforeShow.apply(input, [input, inst]) : {};
    if (beforeShowSettings === false) {
        return;
    }
    extendRemove(inst.settings, beforeShowSettings);

    inst.lastVal = null;
    $.datepicker._lastInput = input;
    $.datepicker._setDateFromField(inst);

    if ($.datepicker._inDialog) { // hide cursor
        input.value = "";
    }
    if (!$.datepicker._pos) { // position below input
        $.datepicker._pos = $.datepicker._findPos(input);
        $.datepicker._pos[1] += input.offsetHeight; // add the height
    }

    isFixed = false;
    $(input).parents().each(function() {
        isFixed |= $(this).css("position") === "fixed";
        return !isFixed;
    });

    offset = {
        left: $.datepicker._pos[0],
        top: $.datepicker._pos[1]
    };
    $.datepicker._pos = null;
    //to avoid flashes on Firefox
    inst.dpDiv.empty();
    // determine sizing offscreen
    inst.dpDiv.css({
        position: "absolute",
        display: "block",
        top: "-1000px"
    });
    $.datepicker._updateDatepicker(inst);
    // fix width for dynamic number of date pickers
    // and adjust position before showing
    offset = $.datepicker._checkOffset(inst, offset, isFixed);
    inst.dpDiv.css({
        position: ($.datepicker._inDialog && $.blockUI ?
            "static" : (isFixed ? "fixed" : "absolute")),
        display: "none",
        left: offset.left + "px",
        top: offset.top + "px"
    }).attr("tabindex", "-1");

    if (!inst.inline) {
        showAnim = $.datepicker._get(inst, "showAnim");
        duration = $.datepicker._get(inst, "duration");
        inst.dpDiv.zIndex($(input).zIndex() + 1);
        $.datepicker._datepickerShowing = true;

        if ($.effects && $.effects.effect[showAnim]) {
            inst.dpDiv.show(showAnim, $.datepicker._get(inst, "showOptions"), duration);
        } else {
            inst.dpDiv[showAnim || "show"](showAnim ? duration : null);
        }

        $('#liveText-polite').text('Datepicker has opened');

        inst.dpDiv.focus().off('keydown').on('keydown', function(event) {
            $.datepicker._doKeyDown(event, input);
        });

        if ($.datepicker._shouldFocusInput(inst)) {
            //inst.input.focus();
        }

        $.datepicker._curInst = inst;
    }
}

$.datepicker._doKeyDown = function(event, input) {
    var onSelect, dateStr, sel,
        inst = (input !== undefined) ? $.datepicker._getInst(input) : $.datepicker._getInst(event.target),
        handled = true,
        isRTL = inst.dpDiv.is(".ui-datepicker-rtl");

    inst._keyEvent = true;

    if ($.datepicker._datepickerShowing) {
        switch (event.keyCode) {
            case 9:
                handled = true;
                break; // hide on tab out
            case 13:
                sel = $("td." + $.datepicker._dayOverClass + ":not(." +
                    $.datepicker._currentClass + ")", inst.dpDiv);
                if (sel[0]) {
                    $.datepicker._selectDay(inst.input[0], inst.selectedMonth, inst.selectedYear, sel[0]);
                }

                onSelect = $.datepicker._get(inst, "onSelect");
                if (onSelect) {
                    dateStr = $.datepicker._formatDate(inst);

                    // trigger custom callback
                    onSelect.apply((inst.input ? inst.input[0] : null), [dateStr, inst]);
                } else {
                    $.datepicker._hideDatepicker();
                    inst.input.focus();
                }

                return false; // don't submit the form
            case 27:
                $.datepicker._hideDatepicker();
                inst.input.focus();
                break; // hide on escape
            case 33:
                $.datepicker._adjustDate(inst.input[0], (event.altKey ?
                    -$.datepicker._get(inst, "stepBigMonths") :
                    -$.datepicker._get(inst, "stepMonths")), "M");
                break; // previous month/year on page up/+ alt
            case 34:
                $.datepicker._adjustDate(inst.input[0], (event.altKey ?
                    +$.datepicker._get(inst, "stepBigMonths") :
                    +$.datepicker._get(inst, "stepMonths")), "M");
                break; // next month/year on page down/+ alt
            case 35:
                $.datepicker._adjustDate(inst.input[0], (isRTL ? -($.datepicker._getDaysInMonth(inst.selectedYear, inst.selectedMonth) - inst.selectedDay) : +($.datepicker._getDaysInMonth(inst.selectedYear, inst.selectedMonth) - inst.selectedDay)), "D");
                handled = event.ctrlKey || event.metaKey;
                break; // clear on alt or command +end
            case 36:
                $.datepicker._adjustDate(inst.input[0], (isRTL ? +(inst.selectedDay - 1) : -(inst.selectedDay - 1)), "D");
                handled = event.ctrlKey || event.metaKey;
                break; // current on alt or command +home
            case 37:
                $.datepicker._adjustDate(inst.input[0], (isRTL ? +1 : -1), "D");
                handled = event.ctrlKey || event.metaKey;
                // -1 day on ctrl or command +left
                break;
            case 38:
                $.datepicker._adjustDate(inst.input[0], -7, "D");
                handled = true;
                break; // -1 week on ctrl or command +up
            case 39:
                $.datepicker._adjustDate(inst.input[0], (isRTL ? -1 : +1), "D");
                handled = event.ctrlKey || event.metaKey;
                // +1 day on ctrl or command +right
                break;
            case 40:
                $.datepicker._adjustDate(inst.input[0], +7, "D");
                handled = true;
                break; // +1 week on ctrl or command +down
            default:
                handled = false;
        }
    } else if (event.keyCode === 36 && event.ctrlKey) { // display the date picker on ctrl+home
        $.datepicker._showDatepicker(this);
    } else {
        handled = false;
    }

    if (handled) {
        event.preventDefault();
        event.stopPropagation();
    }
}

$.datepicker._shouldFocusInput = function(inst) {
    return false;
}

$.datepicker._hideDatepicker = function(input) {
    var showAnim, duration, postProcess, onClose,
        inst = this._curInst;

    if (!inst || (input && inst !== $.data(input, PROP_NAME))) {
        return;
    }

    if (this._datepickerShowing) {
        showAnim = this._get(inst, "showAnim");
        duration = this._get(inst, "duration");
        postProcess = function() {
            $.datepicker._tidyDialog(inst);
        };

        // DEPRECATED: after BC for 1.8.x $.effects[ showAnim ] is not needed
        if ($.effects && ($.effects.effect[showAnim] || $.effects[showAnim])) {
            inst.dpDiv.hide(showAnim, $.datepicker._get(inst, "showOptions"), duration, postProcess);
        } else {
            inst.dpDiv[(showAnim === "slideDown" ? "slideUp" :
                (showAnim === "fadeIn" ? "fadeOut" : "hide"))]((showAnim ? duration : null), postProcess);
        }

        if (!showAnim) {
            postProcess();
        }
        this._datepickerShowing = false;

        onClose = this._get(inst, "onClose");
        if (onClose) {
            onClose.apply((inst.input ? inst.input[0] : null), [(inst.input ? inst.input.val() : ""), inst]);
        }

        inst.trigger.focus();

        this._lastInput = null;
        if (this._inDialog) {
            this._dialogInput.css({
                position: "absolute",
                left: "0",
                top: "-100px"
            });
            if ($.blockUI) {
                $.unblockUI();
                $("body").append(this.dpDiv);
            }
        }
        this._inDialog = false;
    }
}

$.datepicker._attachments = function(input, inst) {
    var showOn, buttonText, buttonImage, buttonClass,
        appendText = this._get(inst, "appendText"),
        isRTL = this._get(inst, "isRTL");

    if (inst.append) {
        inst.append.remove();
    }
    if (appendText) {
        inst.append = $("<span class='" + this._appendClass + "'>" + appendText + "</span>");
        input[isRTL ? "before" : "after"](inst.append);
    }

    input.unbind("focus", this._showDatepicker);

    if (inst.trigger) {
        inst.trigger.remove();
    }

    showOn = this._get(inst, "showOn");
    if (showOn === "focus" || showOn === "both") { // pop-up date picker when in the marked field
        input.focus(this._showDatepicker);
    }
    if (showOn === "button" || showOn === "both") { // pop-up date picker when button clicked
        buttonText = this._get(inst, "buttonText");
        buttonImage = this._get(inst, "buttonImage");
        buttonClass = this._get(inst, "buttonClass");
        inst.trigger = $(this._get(inst, "buttonImageOnly") ?
            $("<img/>").addClass(this._triggerClass).attr({
                src: buttonImage,
                alt: buttonText,
                title: buttonText
            }) :
            $('<span class="input-group-btn"></span>').html(
                $('<button type="button" class="btn btn-default"></button>').addClass(this._triggerClass).html(function() {
                    if (!buttonImage && !buttonClass) {
                        return buttonText;
                    } else if (!buttonClass) {
                        return $("<img/>").attr({
                            src: buttonImage,
                            alt: buttonText,
                            title: buttonText
                        });
                    } else {
                        return $("<span/>").html('<span class="' + buttonClass + '"><span class="adobeBlank">Calendar icon</span></span><span class="sr-only">' + buttonText + '</span>');
                    }
                })
            ));

        input[isRTL ? "before" : "after"](inst.trigger);
        inst.trigger.click(function() {
            if ($.datepicker._datepickerShowing && $.datepicker._lastInput === input[0]) {
                $.datepicker._hideDatepicker();
                input.focus();
            } else if ($.datepicker._datepickerShowing && $.datepicker._lastInput !== input[0]) {
                $.datepicker._hideDatepicker();
                $.datepicker._showDatepicker(input[0]);
            } else {
                $.datepicker._showDatepicker(input[0]);
            }
            return false;
        });
    }
}

/* jQuery extend now ignores nulls! */
function extendRemove(target, props) {
        $.extend(target, props);
        for (var name in props) {
            if (props[name] == null) {
                target[name] = props[name];
            }
        }
        return target;
    }
    /* end of jquery ui datepicker extends */