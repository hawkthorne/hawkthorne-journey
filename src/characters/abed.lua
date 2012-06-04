local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'ABED NADIR'
plyr.offset = 8
plyr.costumes = {
    {name='Abed Nadir', sheet='images/abed.png'},
    {name='Alien Abed', sheet='images/abed_alien.png'},
    {name='Bruce Nadir', sheet='images/abed_batman.png'},
    {name='Joey', sheet='images/abed_white.png'},
}

function plyr.new(sheet)
    local new_plyr = {}

    if sheet == nil then
        new_plyr.sheet = love.graphics.newImage('images/abed.png')
    else
        new_plyr.sheet = love.graphics.newImage(sheet)
    end

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

