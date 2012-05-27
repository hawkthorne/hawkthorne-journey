local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'SHIRLEY BENNET'
plyr.sheet = love.graphics.newImage('images/shirley.png')
plyr.sheet:setFilter('nearest', 'nearest')
local g = anim8.newGrid(48, 48, plyr.sheet:getWidth(), plyr.sheet:getHeight())

plyr.animations = {
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
return plyr
