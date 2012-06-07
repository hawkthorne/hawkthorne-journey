local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'abed'
plyr.offset = 8
plyr.costumes = {
    {name='Abed Nadir', sheet='images/abed.png'},
    {name='Alien Abed', sheet='images/abed_alien.png'},
    {name='Bruce Nadir', sheet='images/abed_batman.png'},
    {name='Cooperative Calligraphy', sheet='images/abed_bottle.png'},
    {name='Inspector Spacetime', sheet='images/abed_inspector.png'},
    {name='Joey', sheet='images/abed_white.png'},
    {name='Pillowtown', sheet='images/abed_pillow.png'},
    {name='Toga', sheet='images/abed_toga.png'},
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

