local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/shirley'

local plyr = {}
plyr.name = 'shirley'
plyr.offset = 9
plyr.ow = 2
plyr.costumes = {
    {name='Shirley Bennett', sheet='base'},
    {name='Ace of Clubs', sheet='clubs'},
    {name='Big Cheddar', sheet='anime'},
    {name='Chef', sheet='chef'},
    {name='Crayon', sheet='crayon'},
    {name='Harry Potter', sheet='potter'},
    -- {name='Jules Winnfield', sheet='jules'},
    -- {name='Not Miss Piggy', sheet='glenda'},
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
            right = anim8.newAnimation('once', g('9,8'), 1),
            left = anim8.newAnimation('once', g('9,7'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g(2,12), 1),
            left = anim8.newAnimation('once', g(2,11), 1),
        },
        holdwalk = { 
            right = anim8.newAnimation('loop', g('3-4,14'), 0.16),
            left = anim8.newAnimation('loop', g('3-4,13'), 0.16),
        },
        crouch = {
            right = anim8.newAnimation('once', g(8,4), 1),
            left = anim8.newAnimation('once', g(8,3), 1)
        },
        crouchwalk = { --state for walking towards the camera
            right = anim8.newAnimation('loop', g('3-4,3'), 0.16),
            left = anim8.newAnimation('loop', g('3-4,3'), 0.16)
        },
        gaze = {
            right = anim8.newAnimation('once', g(6,4), 1),
            left = anim8.newAnimation('once', g(6,3), 1),
        },
        gazewalk = { --state for walking away from the camera
            right = anim8.newAnimation('loop', g('9,3-4'), 0.16),
            left = anim8.newAnimation('loop', g('9,3-4'), 0.16)
        },
        attack = {
            left = anim8.newAnimation('loop', g('2,9','5,9'), 0.16),
            right = anim8.newAnimation('loop', g('2,10','5,10'), 0.16),
        },
        attackjump = {
            left = anim8.newAnimation('loop', g('2,9','5,9'), 0.16),
            right = anim8.newAnimation('loop', g('2,10','5,10'), 0.16),
        },
        attackwalk = {
            left = anim8.newAnimation('loop', g('1,9','3,9','5,9','6,9'), 0.16),
            right = anim8.newAnimation('loop', g('1,10','3,10','5,10','6,10'), 0.16),
        },
        wieldwalk = { --state for walking while holding a weapon
            left = anim8.newAnimation('loop', g('4,8','5,8','6,8','5,8'), 0.16),
            right = anim8.newAnimation('loop', g('4,7','5,7','6,7','5,7'), 0.16),
        },
        wieldidle = { --state for standing while holding a weapon
            left = anim8.newAnimation('once', g(2,6), 1),
            right = anim8.newAnimation('once', g(2,5), 1),
        },
        wieldjump = { --state for jumping while holding a weapon
            left = anim8.newAnimation('once', g('7,1'), 1),
            right = anim8.newAnimation('once', g('7,2'), 1),
        },
        wieldaction = { --state for swinging a weapon
            left = anim8.newAnimation('once', g('6,8','9,8','3,8','6,8'), 0.09),
            right = anim8.newAnimation('once', g('6,7','9,7','3,7','6,7'), 0.09),
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
