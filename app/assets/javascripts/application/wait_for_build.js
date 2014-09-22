I.wait_for_build = (function ($) {
  var TIMER_SELECTOR = "[data-increment-every-second]";
  var RELOAD_TIMEOUT = 4000;
  var RELOAD_URL = null;

  function initBuildChecker(check_build_url, reload_url) {
    RELOAD_URL = reload_url;
    checkBuild(check_build_url);
  }

  function checkBuild(check_build_url) {
    jQuery.ajax(check_build_url, {dataType: 'json', success: function(build) {
      if( !window.builds ) window.builds = {};
      if( !window.builds[build.id] ) {
        window.builds[build.id] = build;
        enqueueCheckBuild(check_build_url);
      } else {
        var before = window.builds[build.id];
        if( before.status == build.status ) {
          enqueueCheckBuild(check_build_url);
        } else {
          reload();
        }
        window.builds[build.id] = build;
      }
    }});
  }

  function enqueueCheckBuild(check_build_url) {
    setTimeout(function() {
      checkBuild(check_build_url);
    }, RELOAD_TIMEOUT);
  }

  function updateBuildTimers() {
    jQuery(TIMER_SELECTOR).each(function(index, ele) {
      var span = $(ele);
      var seconds = parseInt( span.html() );
      seconds = seconds + 1;
      span.html(seconds);
    });;
  }

  function initReload(reload_url) {
    RELOAD_URL = reload_url;
    resetTimeout();
  }

  function initTimers() {
    if( !window.build_timer_id ) {
      window.build_timer_id = setInterval(updateBuildTimers, 1000);
    }
  }

  function resetTimeout() {
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
    initBuildChecker: initBuildChecker,
    initReload: initReload,
    initTimers: initTimers,
    resetTimeout: resetTimeout
  };
}(jQuery));

jQuery(function() {
  I.wait_for_build.initTimers();
});
