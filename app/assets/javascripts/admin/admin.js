// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require morris
//= require rdash
//= require ../application/base
//= require_tree ../application


jQuery(function($) {

  $("[data-scroll-down]").each(function(index, element) {
    element.scrollTop = element.scrollHeight;
  });

  var applyTriggerCheckbox = function(element) {
    var what = $(element).data("filter-build-trigger");
    if( element.checked ) {
      $("[data-build-trigger="+what+"]").show();
    } else {
      $("[data-build-trigger="+what+"]").hide();
    }
  };

  $("[data-filter-build-trigger]").each(function(index, element) {
    applyTriggerCheckbox(element);
  }).click(function(event) {
    applyTriggerCheckbox(event.target);
  });

});
