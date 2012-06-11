local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'jeff'
plyr.offset = 6
plyr.ow = 4
plyr.costumes = {
    {name='Jeff Winger', sheet='images/jeff.png'},
    {name='Darkest Timeline', sheet='images/jeff_dark.png'},
    {name='David Beckham', sheet='images/jeff_david.png'},
    {name='Dean Pelton', sheet='images/jeff_dean.png'},
    {name='King of Spades', sheet='images/jeff_spades.png'},
    {name='Kool Kat', sheet='images/jeff_cool.png'},
    {name='Ricky Nightshade', sheet='images/jeff_ricky.png'},
    {name='Seacrest Hulk', sheet='images/jeff_hulk.png'},
    {name='Short Shorts', sheet='images/jeff_shorts.png'},
}

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    new_plyr.animations = {
        jump = {
            right = anim8.newAnimation('once', g('7,2'), 1),
            left = anim8.newAnimation('once', g('7,1'), 1)
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }
    return new_plyr
end

return plyr
