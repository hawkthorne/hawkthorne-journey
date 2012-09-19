local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/annie'

local plyr = {}
plyr.name = 'annie'
plyr.offset = 14
plyr.ow = 3
plyr.costumes = {
    {name='Annie Edison', sheet='images/annie.png'},
    {name='Asylum', sheet='images/annie_asylum.png'},
    -- {name='Ace of Hearts', sheet='images/annie_hearts.png'},
    {name='Annie Kim', sheet='images/annie_kim.png'},
    {name='Armor', sheet='images/annie_armor.png'},
    {name='Campus Security', sheet='images/annie_security.png'},
    {name='Geneva', sheet='images/annie_geneva.png'},
    -- {name='Little Red Riding Hood', sheet='images/annie_riding.png'},
    {name='Sexy Santa', sheet='images/annie_santa.png'},
}

local beam = love.graphics.newImage('images/annie_beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')
    new_plyr.positions = position_matrix_main

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 223, beam:getWidth(),
        beam:getHeight())

    new_plyr.beam = beam
    new_plyr.animations = {
        dead = {
            right = anim8.newAnimation('once', g('9,2'), 1),
            left = anim8.newAnimation('once', g('9,1'), 1)
        },
        crouch = {
            right = anim8.newAnimation('once', g('9,5'), 1),
            left = anim8.newAnimation('once', g('9,6'), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('2-3,3'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,3'), 0.16),
        },
        hold = {
            right = anim8.newAnimation('once', g(5,7), 1),
            left = anim8.newAnimation('once', g(5,8), 1),
        },
        holdwalk = { 
            right = anim8.newAnimation('loop', g('7-9,9', '8,9'), 0.16),
            left = anim8.newAnimation('loop', g('7-9,10', '8,10'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(8,2), 1),
            left = anim8.newAnimation('once', g(8,1), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,4'), 0.16),
        },
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
