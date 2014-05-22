if( !window.I ) window.I = {};

if( !window.log ) window.log = function() {
  if( console && console.log ) {
    console.log.apply(console, arguments);
  }
};
