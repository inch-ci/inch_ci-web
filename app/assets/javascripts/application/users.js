I.user = (function ($) {
  function syncProjects(url) {
    $('#syncing').show();
    $("a[data-sync-projects]").hide();
    $.ajax(url, {dataType: 'script', method: 'POST'});
  }

  return {
    syncProjects: syncProjects
  };
}(jQuery));

jQuery(function($) {
  $("body").on("click", "a[data-sync-projects]", function(evt) {
    evt.preventDefault();
    evt.stopPropagation();
    I.user.syncProjects(this.href);
  });
});
