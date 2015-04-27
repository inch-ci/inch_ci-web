I.gossip = (function () {
  function onNewBuild(payload) {
    console.log(payload);
    var html = template.replace('{{build_id}}', payload.build_id)
                        .replace('{{build_number}}', payload.build_number)
                        .replace('{{build_status}}', payload.build_status);
    $('.history-builds').prepend(html);
    updateRemotely(payload.build_id);
  }

  function onUpdateBuild(payload) {
    console.log(payload);
    updateRemotely(payload.build_id);
  }

  function updateRemotely(build_id) {
    var url = "/builds/"+build_id+"/history_show.js";
    jQuery.ajax(url);
  }


  function showMore(revision_diff_id) {
    $("tr[data-negative-priority="+revision_diff_id+"]").show();
    $("a[data-show-negative-priority="+revision_diff_id+"]").parents("tr").hide();
  }

  return {
    onNewBuild: onNewBuild,
    onUpdateBuild: onUpdateBuild,
    updateRemotely: updateRemotely,
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

var template = '<div class="history-build-wrapper" data-build-id="{{build_id}}">  <table class="table table-striped history">    <tbody>      <tr>        <td class="status {{build_status}}">          #{{build_number}}        </td>        <td class="revision_uid">          New build        </td>        <td class="duration">        </td>        <td class="finished_at">        </td>      </tr>    </tbody>  </table></div>';
