import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument('lua', type=argparse.FileType('r'),
                    help='Character lua file')
args = parser.parse_args()
start = False
lines = []

for line in args.lua:
    if '.animations' in line:
        start = True
        continue

    if '}' == line.strip():
        start = False

    if start:
        lines.append(line.strip())


states = []
for line in lines:
    if '{' in line:
        states.append((line, []))
        continue

    if '}' in line:
        continue

    if 'warp' in line:
        continue

    states[-1][1].append(line)

animations = []

def get_frames(frames):
    kind, values, duration = frames

    sequence = []

    if isinstance(values, basestring):
        values = [values]

    for v in values:
        if isinstance(v, basestring):
            x,y = v.split(',')

            if '-' in x:
                start, stop = x.split('-')

                for i in range(int(start), int(stop) + 1):
                    sequence.append(i)
                    sequence.append(int(y))
            elif '-' in y:
                start, stop = y.split('-')

                for i in range(int(start), int(stop) + 1):
                    sequence.append(int(x))
                    sequence.append(i)
            else:
                sequence.append(int(x))
                sequence.append(int(y))
        else:
            sequence.append(v)

    return kind == 'loop', zip(sequence[::2], sequence[1::2]), duration
    

animations = []

for state, children in states:
    animation = {}
    name, _ = state.split('=')

    animation['name'] = name.strip()
    animation['sprites'] = []

    for sprite in children:
        direction, frames = sprite.split('=')
        frames = frames.replace('anim8.newAnimation', '')
        frames = frames.replace('g', '').strip()
        if frames[-1] == ',':
            frames = frames[:-1]

        loop, frames, duration = get_frames(eval(frames))

        animation['sprites'].append({
            'direction': direction.strip(),
            'frames': frames,
            'loop': loop,
            'step': duration,
        })

    animations.append(animation)

print json.dumps({
    'character': args.lua.name,
    'animations': animations,
})

