SC.initialize({
  client_id: '1e09987d05ca373c2d2384b077b4221c'
});

function makePlaylist(element) {

  var items = element.find("ul a");
  var currentItem = 0;
  var widget = undefined;

  function playTrack(link, options) {
    currentItem = items.index(link);

    var url = link.attr('href');
    options = options || {};
    options.show_artwork = false;
    options.sharing = false;

    if (widget === undefined) {
      SC.oEmbed(url, options, function(oEmbed) {
        element.find(".widget").html(oEmbed.html);

        widget = SC.Widget(element.find("iframe").get(0));

        widget.bind(SC.Widget.Events.FINISH, function(e) {
          currentItem += 1;

          if (currentItem >= items.length) {
            currentItem = 0;
          }

          var link = items.get(currentItem);

          widget.load(link.href, {
            auto_play: true,
            show_artwork: false,
            sharing: false,
          });
        });
      });
    } else {
      widget.load(url, options);
    }
  }

  element.find("ul").on("click", "a", function(e) {
    e.preventDefault();
    item = $(e.target);
    playTrack(item, {auto_play: true});
  });

  playTrack(items.first());
}

