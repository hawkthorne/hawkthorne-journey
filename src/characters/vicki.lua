local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/vicki'

local plyr = {}
plyr.name = 'vicki'
plyr.offset = 7
plyr.ow = 17
plyr.costumes = {
    {name='Vicki Cooper', sheet='base'}
}

local beam = love.graphics.newImage('images/characters/' .. plyr.name .. '/beam.png')

function plyr.new(sheet)
    local new_plyr = {}
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
            right = anim8.newAnimation('once', g('3,5'), 1),
            left = anim8.newAnimation('once', g('3,6'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g('1,12'), 1),
            left = anim8.newAnimation('once', g('1,11'), 1),
        },
        holdwalk = { 
            right = anim8.newAnimation('loop', g('4,12', '1,12', '5,12', '1,12'), 0.16),
            left = anim8.newAnimation('loop', g('4,11', '1,11', '5,11', '1,11'), 0.16),
        },
        crouch = {
            right = anim8.newAnimation('once', g('7,4'), 1),
            left = anim8.newAnimation('once', g('7,3'), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('3-4,3'), 0.16),
            right = anim8.newAnimation('loop', g('3-4,3'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g('5,2'), 1),
            left = anim8.newAnimation('once', g('5,1'), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('3-4,4'), 0.16),
            right = anim8.newAnimation('loop', g('3-4,4'), 0.16),
        },
        attack = {
            left = anim8.newAnimation('loop', g('8-9,1'), 0.16),
            right = anim8.newAnimation('loop', g('8-9,2'), 0.16),
        },
        attackjump = {
            left = anim8.newAnimation('loop', g('1-2,13'), 0.16),
            right = anim8.newAnimation('loop', g('1-2,14'), 0.16),
        },
        attackwalk = {
            left = anim8.newAnimation('loop', g('1,9','6,9','3,9','6,9'), 0.16),
            right = anim8.newAnimation('loop', g('1,10','6,10','3,10','6,10'), 0.16),
        },
        jump = {
            left = anim8.newAnimation('once', g('7,1'), 1),
            right = anim8.newAnimation('once', g('7,2'), 1)
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16),
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1),
        },
        warp = anim8.newAnimation('once', warp('1-4,1'), 0.08),
    }
    return new_plyr
end

return plyr
