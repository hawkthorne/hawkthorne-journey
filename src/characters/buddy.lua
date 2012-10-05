local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/buddy'

local plyr = {}
plyr.name = 'buddy'
plyr.offset = 7
plyr.ow = 11
plyr.costumes = {
    {name='Buddy', sheet='base'},
    {name='Master Exploder', sheet='master_exploder'}
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
            right = anim8.newAnimation('once', g('6,4'), 1),
            left = anim8.newAnimation('once', g('5,4'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g(7,6), 1),
            left = anim8.newAnimation('once', g(7,7), 1),
        },
        holdwalk = { 
            right = anim8.newAnimation('loop', g('7,8', '7,6'), 0.16),
            left = anim8.newAnimation('loop', g('7,9', '7,7'), 0.16),
        },
        crouch = {
            right = anim8.newAnimation('once', g('8,4'), 1),
            left = anim8.newAnimation('once', g('7,4'), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('2-3,5'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,5'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(6,1), 1),
            left = anim8.newAnimation('once', g(7,1), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('5-6,5'), 0.16),
            right = anim8.newAnimation('loop', g('5-6,5'), 0.16),
        },
        attack = {
            left = anim8.newAnimation('loop', g('2-4,7'), 0.16),
            right = anim8.newAnimation('loop', g('2-4,6'), 0.16),
        },
        jump = {
            right = anim8.newAnimation('once', g('9,2'), 1),
            left = anim8.newAnimation('once', g('9,1'), 1)
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

