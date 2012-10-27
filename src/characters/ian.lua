local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/ian'

local plyr = {}
plyr.name = 'ian'
plyr.offset = 2
plyr.ow = 15
plyr.costumes = {
    {name='Ian Duncan', sheet='base'}
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
            left = anim8.newAnimation('once', g('9,6'), 1),
            right = anim8.newAnimation('once', g('9,5'), 1)
        },
        hold = {
            left = anim8.newAnimation('once', g('1,8'), 1),
            right = anim8.newAnimation('once', g('1,7'), 1)
        },
        holdwalk = { 
            left = anim8.newAnimation('loop', g('1-3,10', '2,10'), 0.16),
            right = anim8.newAnimation('loop', g('1-3,9', '2,9'), 0.16)
        },
        crouch = {
            left = anim8.newAnimation('once', g('1,5'), 1),
            right = anim8.newAnimation('once', g('1,6'), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('8-9,1'), 0.16),
            right = anim8.newAnimation('loop', g('8-9,1'), 0.16)
        },
        gaze = {
            left = anim8.newAnimation('once', g('9,3'), 1),
            right = anim8.newAnimation('once', g('9,4'), 1)
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('8-9,2'), 0.16),
            right = anim8.newAnimation('loop', g('8-9,2'), 0.16)
        },
        attack = {
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,3'), 0.16)
        },
        attackjump = {
            left = anim8.newAnimation('loop', g('7-8,3'), 0.16),
            right = anim8.newAnimation('loop', g('7-8,4'), 0.16)
        },
        attackwalk = {
            left = anim8.newAnimation('loop', g('7,6', '5,14', '5,6', '5,14'), 0.16),
            right = anim8.newAnimation('loop', g('5,5', '2,14', '7,5', '2,14'), 0.16)
        },
        jump = {
            left = anim8.newAnimation('once', g('1,3'), 1),
            right = anim8.newAnimation('once', g('1,4'), 1)
        },
        walk = {
            left = anim8.newAnimation('loop', g('5-7,1', '6,1'), 0.16),
            right = anim8.newAnimation('loop', g('5-7,2', '6,2'), 0.16)
        },
        idle = {
            left = anim8.newAnimation('once', g('1,1'), 1),
            right = anim8.newAnimation('once', g('1,2'), 1)
        },
        warp = anim8.newAnimation('once', warp('1-4,1'), 0.08)
    }
    return new_plyr
end

return plyr
