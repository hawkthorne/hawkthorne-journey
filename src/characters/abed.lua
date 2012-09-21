local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/abed'

local plyr = {}
plyr.name = 'abed'
plyr.offset = 5
plyr.ow = 7
plyr.costumes = {
    {name='Abed Nadir', sheet='images/abed.png'},
    {name='Alien', sheet='images/abed_alien.png'},
    {name='Batman', sheet='images/abed_batman.png'},
    {name='Bumblebee', sheet='images/abed_bee.png'},
    -- {name='Cooperative Calligraphy', sheet='images/abed_bottle.png'},
    {name='Christmas Sweater', sheet='images/abed_christmas.png'},
    {name='Covered In Paint', sheet='images/abed_paint.png'},
    {name='Cowboy', sheet='images/abed_cowboy.png'},
    {name='Evil Abed', sheet='images/abed_evil.png'},
    -- {name='Frycook', sheet='images/abed_frycook.png'},
    {name='Gangster', sheet='images/abed_gangster.png'},
    {name='Han Solo', sheet='images/abed_solo.png'},
    {name='Inspector Spacetime', sheet='images/abed_inspector.png'},
    -- {name='Jack of Clubs', sheet='images/abed_clubs.png'},
    {name='Jeff Roleplay', sheet='images/abed_jeff.png'},
    {name='Joey', sheet='images/abed_white.png'},
    {name='Morning', sheet='images/abed_morning.png'},
    {name='Mouse King', sheet='images/abed_king.png'},
    {name='Pierce Roleplay', sheet='images/abed_pierce.png'},
    -- {name='Pillowtown', sheet='images/abed_pillow.png'},
    -- {name='Rod the Plumber', sheet='images/abed_rod.png'},
    -- {name='Toga', sheet='images/abed_toga.png'},
    {name='Troy and Abed Sewn Together', sheet='images/abed_sewn.png'},
    {name='Zombie', sheet='images/abed_zombie.png'},
}

local beam = love.graphics.newImage('images/abed_beam.png')

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

