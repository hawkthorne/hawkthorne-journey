local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/fatneil'

local plyr = {}
plyr.name = 'fatneil'
plyr.offset = 6
plyr.ow = 9
plyr.costumes = {
    {name='Fat Neil', sheet='base'},
}

local beam = love.graphics.newImage('images/characters/' .. plyr.name .. '/beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.name = plyr.name
    new_plyr.offset = plyr.offset
    new_plyr.ow = plyr.ow
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')
    new_plyr.positions = position_matrix_main

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 300, beam:getWidth(),
        beam:getHeight())

    new_plyr.beam = beam
    new_plyr.animations = {
        dead = {
            right = anim8.newAnimation('once', g('4,6'), 1),
            left = anim8.newAnimation('once', g('4,5'), 1)
        },
        crouch = {
            right = anim8.newAnimation('once', g(3,6), 1),
            left = anim8.newAnimation('once', g(3,5), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('3-4,3'), 0.16),
            right = anim8.newAnimation('loop', g('3-4,3'), 0.16),
        },
        hold = {
            right = anim8.newAnimation('once', g(7,9), 1),
            left = anim8.newAnimation('once', g(7,10), 1),
        },
        holdwalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('1-2,12'), 0.16),
            right = anim8.newAnimation('loop', g('1-2,11'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(5,2), 1),
            left = anim8.newAnimation('once', g(5,1), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,4'), 0.16),
        },
        attack = {
            left = anim8.newAnimation('loop', g('8-9,1'), 0.16),
            right = anim8.newAnimation('loop', g('8-9,2'), 0.16),
        },
        attackjump = {
            left = anim8.newAnimation('loop', g('1-2,14'), 0.16),
            right = anim8.newAnimation('loop', g('1-2,13'), 0.16),
        },
        attackwalk = {
            left = anim8.newAnimation('loop', g('1,10','3,10','6,10','3,10'), 0.16),
            right = anim8.newAnimation('loop', g('1,9','3,9','6,9','3,9'), 0.16),
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
        flyin = anim8.newAnimation('once', g('2,3'), 1),
        warp = anim8.newAnimation('once', warp('1-4,1'), 0.08),
    }
    return new_plyr
end

return plyr
