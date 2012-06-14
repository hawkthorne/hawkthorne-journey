local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'abed'
plyr.offset = 8
plyr.ow = 7
plyr.costumes = {
    {name='Abed Nadir', sheet='images/abed.png'},
    {name='Alien Abed', sheet='images/abed_alien.png'},
    {name='Batman Abed', sheet='images/abed_batman.png'},
    {name='Bumblebee', sheet='images/abed_bee.png'},
    {name='Cooperative Calligraphy', sheet='images/abed_bottle.png'},
    {name='Frycook', sheet='images/abed_frycook.png'},
    {name='Inspector Spacetime', sheet='images/abed_inspector.png'},
    {name='Jack of Clubs', sheet='images/abed_clubs.png'},
    {name='Joey', sheet='images/abed_white.png'},
    {name='Pillowtown', sheet='images/abed_pillow.png'},
    {name='Rod the Plumber', sheet='images/abed_rod.png'},
    {name='Toga', sheet='images/abed_toga.png'},
}

local beam = love.graphics.newImage('images/abed_beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(), 
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 223, beam:getWidth(),
        beam:getHeight())

    new_plyr.beam = beam
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
        },
        warp = anim8.newAnimation('once', warp('1-4,1'), 0.08),
    }
    return new_plyr
end

return plyr

