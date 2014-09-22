I.dom = (function ($) {
  function updateIfChanged(selector, new_content) {
    var ele = $(selector);
    var parsed = $('<div/>').html(new_content);
    if( removeWhitespace(ele.html()) != removeWhitespace(parsed.html()) ) {
      ele.html(new_content);
    }
  }

  function removeWhitespace(str) {
    return str.replace(/^(\s*)/gm, '');
  }

  return {
    updateIfChanged: updateIfChanged
  };
}(jQuery));
