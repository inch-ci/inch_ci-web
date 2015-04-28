I.gossip = (function () {
  function onNewBuild(payload) {
    console.log("Unhandled :new_build message", payload);
  }

  function onUpdateBuild(payload) {
    console.log("Unhandled :update_build message", payload);
  }


  function showMore(revision_diff_id) {
    $("tr[data-negative-priority="+revision_diff_id+"]").show();
    $("a[data-show-negative-priority="+revision_diff_id+"]").parents("tr").hide();
  }

  return {
    onNewBuild: onNewBuild,
    onUpdateBuild: onUpdateBuild,
    showMore: showMore
  };
}());

var Socket = require("phoenix").Socket;

jQuery(function() {
  var socket_server = $('body').data('gossip-server');
  var room = $('body').data('gossip-room');
  if( socket_server && room ) {
    console.log('Loading Gossip ... (room: '+room+')')

    var socket = new Socket("ws://"+socket_server+"/ws");
    socket.connect();

    socket.join(room, {}).receive("ok", function (chan) {
      console.log('On Gossip')
      chan.on("new_build", function (payload) {
        I.gossip.onNewBuild(payload);
      });
      chan.on("update_build", function (payload) {
        I.gossip.onUpdateBuild(payload);
      });
    });
  }
});
