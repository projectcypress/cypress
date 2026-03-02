//  HCM Detection 5/12/15 v1.0.0

var HCDetect = (function($) {
    /*
     * Set up properties
     * @property {Object}   hc - Module object (short hand).
     * @property {string}   imgFile - Path to image file
     * @property {string}   bdrColor - Background color
     * @property {string}   cssImg - URL to image used for the background-image CSS property
     * @property {string}   sampleFontFamily - Font family list
     * @return {Object}     Return Nav object
     */
    var hc = {},
        imgFile = 'vendor/globalassets/images/clear.gif',
        bdrColor = 'rgb(128, 4, 146)',
        bgColor = 'rgb(4, 92, 131)',
        cssImg = 'url("' + imgFile + '")',
        sampleFontFamily = 'Georgia, Arial, fantasy, cursive, serif';

    /* Generates the test DOM used for High Contrast testing.
     * @method createDOM
     * @private
     * @return {void}
     */
    function createDOM() {
        // Make sure DOM exist.
        if ($('#hcTest').length === 0) {
            // Create DOM object for testing.
            $('body').prepend($('<div>', {
                id: 'hcTest',
            }).css({
                'border-color': bdrColor,
                'font-family': sampleFontFamily,
                'background': 'url(' + imgFile + ')' + bgColor,
                'text-shadow': 'none',
                'position': 'absolute',
                'left': '-9999em',
                'height': '0',
                'width': '0'
            }).prepend('<img src="' + imgFile + '">'));

            // Browser detect using DOM sniffing.
            if ($('#hcTest').css('text-shadow')) {
                $('#hcTest').css('border-color', '#800492');
            }

        }
    }

    /* Checks if whether or not images are disabled or enabled.
     * @method isImageEnabled
     * @private
     * @return {Boolean}
     */
    function isImageEnabled() {
        var isEnabled = true,
            imgGen;

        createDOM();
        return isEnabled;
    };

    /* Checks if whether or not background images used in CSS are disabled or enabled.
     * @method isBackgroundImageEnabled
     * @private
     * @return {Boolean}
     */
    function isBackgroundImageEnabled() {
        var isEnabled = true;
        createDOM();
        if ($('#hcTest').css("background-image") == 'none') {
            isEnabled = false;
        }
        return isEnabled;
    };

    /* Checks if whether or not custom fonts are disabled or enabled.
     * @method isCustomFont
     * @private
     * @return {Boolean}
     */
    function isCustomFont() {
        var isEnabled = true,
            sampleFontFamilyGen;

        createDOM();
        sampleFontFamily = sampleFontFamily.toLowerCase().replace(/\s+/g, '');
        sampleFontFamilyGen = $('#hcTest').css('font-family').toLowerCase().replace(/\s+/g, '');
        if (sampleFontFamily !== sampleFontFamilyGen) {
            $('html').addClass('ui-helper-nocustomfonts');

            isEnabled = false;
        }
        return isEnabled;
    };

    /* Checks if whether or not the page is in high contrast mode.
     * @method isHighContrast
     * @private
     * @return {Boolean}
     */
    function isHighContrast() {
        var isEnabled = false;
        if (!isBackgroundImageEnabled() || !isImageEnabled()) {
            isEnabled = true;
        }
        return isEnabled;
    };

    /* Checks if whether or not border colors are enabled or not.
     * @method isBorderColorEnabled
     * @private
     * @return {Boolean}
     */
    function isBorderColorEnabled() {
        var isEnabled = false,
            borderColorGen;

        createDOM();
        borderColorGen = $('#hcTest').css("borderTopColor");

        if (bdrColor == borderColorGen) {
            isEnabled = true;
        }
        return isEnabled;
    };

    /* Checks if whether or not the page is in HC mode and if the HC mode is light or dark background.
     * @method contrastMode
     * @private
     * @return {string}
     */
    function contrastMode() {
        var modeType = {},
            isEnabled = false,
            bkgrndColor = $('#hcTest').css('background-color'),
            rgb = '',
            hexBgColor = rgbToHex(bgColor.replace(/[^\d,]/g, '').split(',')),
            fontColor = $('#hcTest').css('color'),
            bkgrndColorTests = ['#000000', '#ffffff'], // black, white
            fontColorTests = ['#ffff00', '00ff00', '#ffffff', '#000000']; // yellow, green, white, black
        // convert rgb color property to hex
        if (bkgrndColor.substring(0) != '#') {
            // convert rgb color property to an array
            rgb = bkgrndColor.replace(/[^\d,]/g, '').split(',');
            bkgrndColor = rgbToHex(rgb);
        }
        // convert rgb color property to hex
        if (fontColor.substring(0) != '#') {
            // convert rgb color property to an array
            rgb = fontColor.replace(/[^\d,]/g, '').split(',');
            fontColor = rgbToHex(rgb);
        }


        // First check if user is in HC mode.
        if (isHighContrast()) {

            if (fontColor >= bkgrndColor) {
                isEnabled = true;
                $('html').addClass('lightOnDark');
            } else {
                isEnabled = false;
                $('html').addClass('darkOnLight');
            }
        }

        return isEnabled;
    };

    /* Checks if whether or not the page is in HC mode and if the HC mode is light or dark background.
     * (modified from http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb)
     * @method rgbToHex
     * @private
     * @param {Object}  rgb - Array of rgb values
     * @property {int}  r - First value in rgb array.
     * @property {int}  g - Second value in rgb array.
     * @property {int}  b - Third value in rgb array.
     * @return {string} Returns color Hex
     */
    function rgbToHex(rgb) {
        var r = parseInt(rgb.slice(0, 1)),
            g = parseInt(rgb.slice(1, 2)),
            b = parseInt(rgb.slice(2, 3)),
            hex;
        hex = '#' + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1);
        return hex;
    }


    /* Initiates class.
     * @method init  Initiates config of nav bar
     * @public
     * @return {void}
     */
    hc.init = function() {
        createDOM();
        if (isHighContrast()) {
            $('html').addClass('ui-helper-highcontrast');
        }
        if (!isCustomFont()) {
            $('html').addClass('ui-helper-nocustomfonts');
        }
        $('#hcTest').remove();
    };
    hc.isHighContrast = isHighContrast();
    hc.isCustomFont = isCustomFont();
    hc.isBackgroundImageEnabled = isBackgroundImageEnabled();
    hc.isImageEnabled = isImageEnabled();
    hc.isBorderColorEnabled = isBorderColorEnabled();
    hc.contrastMode = contrastMode();
    return hc;
})(jQuery);