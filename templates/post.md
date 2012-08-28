**CHANGES**
{% for commit in commits %}
- {{ commit.commit.message }}
{% endfor %}

**KNOWN ISSUES**
{% for bug in bugs %}
- [{{ bug.title }}]({{ bug.html_url }})
{%- endfor %}

**TASKS THAT YOU CAN WORK ON**
{% for feature in features %}
- [{{ feature.title }}]({{ feature.html_url }})
{%- endfor %}

**DOWNLOAD**

- [OS X](https://github.s3.amazonaws.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne-osx.zip)
- [Windows 32-bit](https://github.s3.amazonaws.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne-win-x86.zip)
- [Windows 64-bit](https://github.s3.amazonaws.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne-win-x64.zip)
- [hawkthorne.love](https://github.s3.amazonaws.com/downloads/kyleconroy/hawkthorne-journey/hawkthorne.love)
  You'll need to install the [love](http://love2d.org) framework as well.

**Found a bug? [Report it here](https://docs.google.com/spreadsheet/viewform?pli=1&formkey=dFh5bmRNVWZrdlBHbUVmcmZNczJoaXc6MQ#gid=0)**

