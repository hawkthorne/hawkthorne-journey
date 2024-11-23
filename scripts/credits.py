import jinja2

names = set()

with open('CONTRIBUTORS', 'r') as f:
    for name in f:
        names.add(name.lower().strip())

with open('CONTRIBUTORS', 'w') as f:
    for name in sorted(names):
        name = name.strip()
        if name != "":
            f.write(name + "\n")

template = jinja2.Template(open('templates/credits.lua').read())
print(template.render(contributors=[l.strip().replace("'", "\\'") for l in open('CONTRIBUTORS')]))
