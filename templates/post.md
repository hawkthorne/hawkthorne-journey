Release {{version}}

**FROM THE DEVS**

**CHANGES**
{% for feature in new_features %}
- [{{ feature.title }}]({{ feature.html_url }})
{%- endfor %}

**KNOWN ISSUES**
{% for bug in bugs %}
- [{{ bug.title }}]({{ bug.html_url }})
{%- endfor %}

**INTERESTED IN HELPING OUT?**

Take a look at the list of [open
issues](https://github.com/hawkthorne/hawkthorne-journey/issues?milestone=1&state=open)
that we need fixed before we can get to version 1.0.

**DOWNLOAD**

- [OS X](http://files.projecthawkthorne.com/releases/latest/hawkthorne-osx.zip)
- [Windows 32-bit](http://files.projecthawkthorne.com/releases/latest/hawkthorne-win-x86.zip)
- [Windows 64-bit](http://files.projecthawkthorne.com/releases/latest/hawkthorne-win-x64.zip)
- [hawkthorne.love](http://files.projecthawkthorne.com/releases/latest/hawkthorne.love)
  You'll need to install the [love](http://love2d.org) framework as well.

**Found a bug? [Report it here](https://github.com/hawkthorne/hawkthorne-journey/issues?state=open)**

