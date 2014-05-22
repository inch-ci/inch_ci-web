I.badge_image_markup = (function ($) {

  function showMarkup() {
    $('#badge-image-markup').toggle();
  }

  return {
    showMarkup: showMarkup
  };
}(jQuery));

jQuery(function($) {
  $("body").on("click", "a[data-show-markup]", function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    I.badge_image_markup.showMarkup();
  }).on("click", "input[data-select-on-click]", function(evt) {
    evt.preventDefault();
    $(this).select();
  });
});
