I.badge_image_markup = (function ($) {
  function selectImageFormat(format) {
    $('.badge-image-markup').hide();
    $('.badge-image-markup-'+format).show();
  }

  function showMarkup() {
    $('#badge-image-markup').toggle();
  }

  return {
    selectImageFormat: selectImageFormat,
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
  }).on("click", "input[data-select-badge-format]", function(evt) {
    var format = $(this).data('select-badge-format');
    I.badge_image_markup.selectImageFormat(format);
  });

});
