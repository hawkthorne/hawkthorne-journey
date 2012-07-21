import argparse
import os
import json

parser = argparse.ArgumentParser()
parser.add_argument('input', help='Directory that holds images and sprites.json')
parser.add_argument('output', help='Directory to save gifs')
parser.add_argument('--width', default=9, type=int)
args = parser.parse_args()

name = os.path.basename(args.input)
character = json.load(open(os.path.join(args.input, 'sprites.json')))

for animation in character['animations']:
    movement = animation['name']
    for sprite in animation['sprites']:
        direction = sprite['direction']

        if not sprite['loop']:
            continue

        cmd = "gifsicle --delay {} --loop ".format(int(float(sprite['step']) * 100))

        for frame in sprite['frames']:
            x, y = int(frame[0]), int(frame[1])
            filename = "{}_{:02}.gif ".format(name, x + args.width * (y - 1))
            cmd += os.path.join(args.input, "images", filename) + " "

        cmd = cmd + "> {}/{}_{}_{}.gif".format(args.output, name, movement, direction)

        print cmd
        os.system(cmd)
