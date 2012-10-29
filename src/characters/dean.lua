local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/dean'

local plyr = {}
plyr.name = 'dean'
plyr.offset = 8
plyr.ow = 14
plyr.costumes = {
    {name='Dean Craig Pelton', sheet='base'},
    {name='Devil Dean', sheet='devil'},
    {name='Mardi Gras', sheet='mardigras'},
}

local beam = love.graphics.newImage('images/characters/annie/beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')
    new_plyr.positions = position_matrix_main

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 300, beam:getWidth(),
        beam:getHeight())

    new_plyr.hand_offset = 18
    new_plyr.beam = beam
    new_plyr.animations = {
        dead = {
            right = anim8.newAnimation('once', g('9,5'), 1),
            left = anim8.newAnimation('once', g('9,6'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g(1,7), 1),
            left = anim8.newAnimation('once', g(1,8), 1),
        },
        holdwalk = {
            right = anim8.newAnimation('loop', g('1-3,9', '2,9'), 0.16),
            left = anim8.newAnimation('loop', g('1-3,10', '2,10'), 0.16),
        },
        crouch = {
            right = anim8.newAnimation('once', g('1,6'), 1),
            left = anim8.newAnimation('once', g('1,5'), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('8-9,1'), 0.16),
            right = anim8.newAnimation('loop', g('8-9,1'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(9,4), 1),
            left = anim8.newAnimation('once', g(9,3), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('8-9,2'), 0.16),
            right = anim8.newAnimation('loop', g('8-9,2'), 0.16),
        },
        attack = {
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,3'), 0.16),
        },
        attackjump = {
            left = anim8.newAnimation('loop', g('4-5,3'), 0.16),
            right = anim8.newAnimation('loop', g('4-5,4'), 0.16),
        },
        attackwalk = {
            left = anim8.newAnimation('loop', g('2,6','4,6','6,6','4,6'), 0.16),
            right = anim8.newAnimation('loop', g('2,5','4,5','6,5','4,5'), 0.16),
        },
        jump = {
            right = anim8.newAnimation('once', g('1,4'), 1),
            left = anim8.newAnimation('once', g('1,3'), 1)
        },
        walk = {
            right = anim8.newAnimation('loop', g('5-7,2', '6,2'), 0.16),
            left = anim8.newAnimation('loop', g('5-7,1', '6,1'), 0.16),
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
