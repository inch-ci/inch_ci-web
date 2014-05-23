I.grade_list_table = (function () {

  function showMore(grade) {
    var table = $(".grade-table-"+grade);
    table.find("tr.show_more").hide();
    table.find("tr.hidden_object").show();
  }

  return {
    showMore: showMore
  };
}());

jQuery(function($) {
  $("body").on('click', 'a[data-show-more]', function(evt) {
    evt.preventDefault();
    var grade = $(this).data('show-more');
    I.grade_list_table.showMore(grade);
    return false;
  });

  $("[data-toggle=tooltip]").tooltip({delay: { show: 300, hide: 100 }});
});
