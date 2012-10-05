local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/chang'

local plyr = {}
plyr.name = 'chang'
plyr.offset = 8
plyr.ow = 10
plyr.costumes = {
    {name='Ben Chang', sheet='base'},
    {name='Brutalitops', sheet='brutalitops'},
    {name='Dictator', sheet='dictator'},
    {name='Father', sheet='father'},
    {name='Safety First', sheet='safety'},
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
            right = anim8.newAnimation('once', g('9,13'), 1),
            left = anim8.newAnimation('once', g('9,14'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g(5,5), 1),
            left = anim8.newAnimation('once', g(5,6), 1),
        },
        holdwalk = { 
            right = anim8.newAnimation('loop', g('1-3,9', '2,9'), 0.16),
            left = anim8.newAnimation('loop', g('1-3,10', '2,10'), 0.16),
        },
        crouch = {
            right = anim8.newAnimation('once', g('9,4'), 1),
            left = anim8.newAnimation('once', g('9,3'), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('2-3,3'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,3'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(8,2), 1),
            left = anim8.newAnimation('once', g(8,1), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,4'), 0.16),
        },
        attack = {
            left = anim8.newAnimation('loop', g('3-4,6'), 0.16),
            right = anim8.newAnimation('loop', g('3-4,5'), 0.16),
        },
        attackjump = {
            left = anim8.newAnimation('loop', g('7-8,3'), 0.16),
            right = anim8.newAnimation('loop', g('7-8,4'), 0.16),
        },
        attackwalk = {
            left = anim8.newAnimation('loop', g('1,8','5,8','3,8','5,8'), 0.16),
            right = anim8.newAnimation('loop', g('1,7','5,7','3,7','5,7'), 0.16),
        },
        jump = {
            right = anim8.newAnimation('once', g('7,2'), 1),
            left = anim8.newAnimation('once', g('7,1'), 1)
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

