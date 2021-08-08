import "./gallery.sass"

import 'magnific-popup'
import 'magnific-popup/dist/magnific-popup.css'

import 'slippry/dist/slippry.min.js'
import 'slippry/dist/slippry.css'

$(document).ready(function() {
    console.log("shared");

    if($(".popupImg").length)
        $('.popupImg').magnificPopup({
            type: 'image'
            // other options
        });
    
    $('.open-popup-link').magnificPopup({
        type:'inline',
    });
    $(".gallery-slider").each(function() {
        let slider = $(this);


        var thumbs = $(".gallery-thumbnails", slider).slippry({
            // general elements & wrapper
            slippryWrapper: '<div class="slippry_box thumbnails" />',
            // options
            transition: 'fade',
            pager: false,
            auto: false,
            onSlideBefore: function (el, index_old, index_new) {
                $('.gallery-thumbnail-box a', slider).removeClass('active');
                $('a', $('.gallery-thumbnail-box li', slider)[index_new]).addClass('active');
            }
        });

        $('.gallery-thumbnail-box a', slider).click(function () {
            thumbs.goToSlide($(this).data('slide'));
            return false;
        });

    });

});

