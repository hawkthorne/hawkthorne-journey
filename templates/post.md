**Hawkthorne Release {{version}}**

-- /r/hawkthorne mods

**DOWNLOAD**

- [OS X](http://files.projecthawkthorne.com/releases/latest/hawkthorne-osx.zip)
- [Windows 32-bit](http://files.projecthawkthorne.com/releases/latest/hawkthorne-win-x86.zip)
- [Windows 64-bit](http://files.projecthawkthorne.com/releases/latest/hawkthorne-win-x64.zip)
- [hawkthorne.love](http://files.projecthawkthorne.com/releases/latest/hawkthorne.love)
  You'll need to install the [love](http://love2d.org) framework as well.

**How can I help?**

- [**Play test the game and find bugs**](https://github.com/hawkthorne/hawkthorne-journey/blob/master/CONTRIBUTING.md#playtest)
- [Code new game features](https://github.com/hawkthorne/hawkthorne-journey/blob/master/CONTRIBUTING.md#code)
- [Record music and sound effects](https://github.com/hawkthorne/hawkthorne-journey/blob/master/CONTRIBUTING.md#music-and-sound-effects)
- [Draw sprites and tile sets](https://github.com/hawkthorne/hawkthorne-journey/blob/master/CONTRIBUTING.md#sprites)
- [Create new costumes and characters](https://github.com/hawkthorne/hawkthorne-journey/blob/master/CONTRIBUTING.md#characters-and-costumes)

**CHANGES**
{% for feature in new_features %}
- [{{ feature.title }}]({{ feature.html_url }})
{%- endfor %}
