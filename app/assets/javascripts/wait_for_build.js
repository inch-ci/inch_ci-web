I.wait_for_build = (function ($) {
  var TIMER_SELECTOR = "[data-increment-every-second]";
  var RELOAD_TIMEOUT = 4000;
  var RELOAD_URL = null;

  function updateBuildTimers() {
    jQuery(TIMER_SELECTOR).each(function(index, ele) {
      var span = $(ele);
      var seconds = parseInt( span.html() );
      seconds = seconds + 1;
      span.html(seconds);
    });;
  }

  function initReload(url) {
    RELOAD_URL = url;
    resetTimeout();
  }

  function initTimers() {
    if( !window.build_timer_id ) {
      window.build_timer_id = setInterval(updateBuildTimers, 1000);
    }
  }

  function resetTimeout() {
      log("  -> resetTimeout()")
    setTimeout(reload, RELOAD_TIMEOUT);
  }

  function reload() {
    if( RELOAD_URL ) {
      jQuery.ajax(RELOAD_URL);
    } else {
      log("NO RELOAD URL SET!")
    }
  }

  return {
    initReload: initReload,
    initTimers: initTimers,
    resetTimeout: resetTimeout
  };
}(jQuery));

jQuery(function() {
  I.wait_for_build.initTimers();
});
