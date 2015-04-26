I.history = (function () {

  function showMore(revision_diff_id) {
    $("tr[data-negative-priority="+revision_diff_id+"]").show();
    $("a[data-show-negative-priority="+revision_diff_id+"]").parents("tr").hide();
  }

  return {
    showMore: showMore
  };
}());

jQuery(function($) {
  $("body").on('click', 'a[data-show-negative-priority]', function(evt) {
    evt.preventDefault();
    var revision_diff_id = $(this).data('show-negative-priority');
    I.history.showMore(revision_diff_id);
    return false;
  });
});
