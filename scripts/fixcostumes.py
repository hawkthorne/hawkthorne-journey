import Image
import os

COSTUME_DIR = 'src/images/'
COSTUME_BASE = "src/images/{}.png"

def costumes(name):
    for filename in os.listdir(COSTUME_DIR):
        if filename.startswith(name + '_') and 'beam' not in filename:
            yield COSTUME_DIR + filename

def tiles(image):
    width, height = image.size[0] / 48, image.size[1] / 48

    for x in range(width):
        for y in range(height):
            yield (48 * x, 48 * y, 48 * (x + 1), 48 * (y + 1))


for name in ['abed', 'britta', 'jeff', 'annie', 'troy', 'pierce', 'shirley']:
    image = Image.open(COSTUME_BASE.format(name))
    
    for path in costumes(name):
        costume = Image.open(path)

        if not costume.size == image.size:
            print "Resizing canvas\t{}".format(path)
            new_costume = Image.new('RGBA', image.size)
            new_costume.paste(costume, (0, 0, costume.size[0], costume.size[1]))
            new_costume.save(path)

    for path in costumes(name):
        costume = Image.open(path)
        
        for box in tiles(image):
            h1 = image.crop(box).histogram()
            h2 = costume.crop(box).histogram()
            print h2


        
