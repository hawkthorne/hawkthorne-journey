import os
import jinja2

template = jinja2.Template(open('templates/credits.lua').read())
print template.render(contributors=[l.strip().replace("'", "") for l in open('CONTRIBUTORS')])
