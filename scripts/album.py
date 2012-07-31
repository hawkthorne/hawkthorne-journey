import jinja2

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

side_a = [
    ("Welcome to Hawkthorne (Intro)",
     "http://soundcloud.com/derferman/welcome-to-hawkthorne"),
    ("Press Orange to Jump (Greendale)",
     "http://soundcloud.com/derferman/press-orange-to-jump"),
    ("Worst Son Ever! (Cornelius Appears)",
     "http://soundcloud.com/boobatron/worst-son-ever-cornelius"),
    ("Stay in the Game Pierce (Forest)",
     "http://soundcloud.com/overtoneshock/forest-theme"),
    ("Is He Being Ominous? (Gilbert Attacks)",
     "http://soundcloud.com/overtoneshock/gilbert-attacks"),
    ("A Girl Milking a Cow (Town)",
     "http://soundcloud.com/overtoneshock/town-theme"),
    ("Let's Play Poker (Tavern)",
     "http://soundcloud.com/boobatron/tavern-secret-basement-music"),
    ("Help Me Hide the Body (Blacksmith)",
     "http://soundcloud.com/boobatron/blacksmith-theme-redux-2"),
    ("Comfy at a Cauldron (Secret Potion Lab)",
     "http://soundcloud.com/boobatron/potion-room-theme"),
    ("Playing the Rain Man Card (Abed's Farewell)",
     "http://soundcloud.com/overtoneshock/abeds-farewell"),
    ("Offensive, Called It (Overworld)",
     "http://soundcloud.com/eviltimmy/overworld-theme-loopable"),
    ("Duck, Stay Ducked (Black Caves)",
     "http://soundcloud.com/overtoneshock/black-caves"),
    ("This Is It (Seabluff)",
     "http://soundcloud.com/overtoneshock/sea-bluff-outside-castle"),
    ("Arrows! (Gilbert Attacks Again)",
     "http://soundcloud.com/djnofro/sea-bluff-attack"),
    ("Unlock the Castle (Castle Hawkthorne Entrance)",
     "http://soundcloud.com/overtoneshock/hawkthorne-entrance"),
    ("She Can Make Babies (Abed's Town)",
     "http://soundcloud.com/overtoneshock/abeds-town"),
    ("No Blood Gold To Be Found (Abed's Castle)",
     "http://soundcloud.com/boobatron/abeds-castle"),
    ("First to Make It (Throne of Hawkthorne)",
     "http://soundcloud.com/overtoneshock/inside-castle"),
    ("A Simple Question (Cornelius's Contract)",
     "http://soundcloud.com/overtoneshock/running-away-from-the-throne"),
    ("Die Racism! (Final Boss Fight)",
     "http://soundcloud.com/paintyfilms/vs-cornelius-final-boss"),
    ("We're Forfeiting (Warehouse)",
     "http://soundcloud.com/paintyfilms/were-forfeiting"),
    ("Kill Our Dad and Take The Throne",
     "http://soundcloud.com/justinamason96/hawkthorne-victory-song"),
]

print template.render(sides=[
    {
        "title": "Side A",
        "tracks": [
            {

