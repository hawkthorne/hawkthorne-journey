import jinja2
import requests

template = jinja2.Template("""
<div id="playlist">
  <div class="widget">
  </div>
  <div class="tracks">
    {% for side in sides %}
    <strong>{{ side.title }}</strong>
    <ul class="side">
      {% for track in side.tracks %}
      <li><a href="{{ track.uri }}">{{ track.title }}</a></li>
      {% endfor %}
    </ul>
    {% endfor %}
  </div>
</div>
""")


def resolve(tracks):
    output = []
    for title, uri in tracks:
        output.append({
            "title": title,
            "uri": resolve_track(uri),
            })
    return output


def resolve_track(uri):
    resp = requests.get("https://api.soundcloud.com/resolve.json",
                        params={"url": uri, 
                                "client_id": '1e09987d05ca373c2d2384b077b4221c'})
    return resp.json["uri"]


side_a = [
    ("Welcome to Hawkthorne",
     "http://soundcloud.com/derferman/welcome-to-hawkthorne"),
    ("Press Orange to Jump",
     "http://soundcloud.com/derferman/press-orange-to-jump"),
    ("Worst Son Ever!",
     "http://soundcloud.com/boobatron/worst-son-ever-cornelius"),
    ("Stay in the Game Pierce",
     "http://soundcloud.com/overtoneshock/forest-theme"),
    ("Is He Being Ominous?",
     "http://soundcloud.com/overtoneshock/gilbert-attacks"),
    ("A Girl Milking a Cow",
     "http://soundcloud.com/overtoneshock/town-theme"),
    ("Let's Play Poker",
     "http://soundcloud.com/boobatron/tavern-secret-basement-music"),
    ("Help Me Hide the Body",
     "http://soundcloud.com/boobatron/blacksmith-theme-redux-2"),
    ("Comfy at a Cauldron",
     "http://soundcloud.com/boobatron/potion-room-theme"),
    ("Playing the Rain Man Card",
     "http://soundcloud.com/overtoneshock/abeds-farewell"),
    ("Offensive, Called It",
     "http://soundcloud.com/eviltimmy/overworld-theme-loopable"),
    ("Duck, Stay Ducked",
     "http://soundcloud.com/overtoneshock/black-caves"),
    ("This Is It",
     "http://soundcloud.com/overtoneshock/sea-bluff-outside-castle"),
    ("Arrows!",
     "http://soundcloud.com/djnofro/sea-bluff-attack"),
    ("Unlock the Castle",
     "http://soundcloud.com/overtoneshock/hawkthorne-entrance"),
    ("She Can Make Babies",
     "http://soundcloud.com/overtoneshock/abeds-town"),
    ("No Blood Gold To Be Found",
     "http://soundcloud.com/boobatron/abeds-castle"),
    ("First to Make It",
     "http://soundcloud.com/overtoneshock/inside-castle"),
    ("A Simple Question",
     "http://soundcloud.com/overtoneshock/running-away-from-the-throne"),
    ("Die Racism!",
     "http://soundcloud.com/paintyfilms/vs-cornelius-final-boss"),
    ("We're Forfeiting",
     "http://soundcloud.com/paintyfilms/were-forfeiting"),
    ("Kill Our Dad and Take The Throne",
     "http://soundcloud.com/justinamason96/hawkthorne-victory-song"),
]

print template.render(sides=[
    {"title": "Side A - Soundtrack", "tracks": resolve(side_a)},
    ])

