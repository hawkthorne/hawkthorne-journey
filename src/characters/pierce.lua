local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/pierce'

local plyr = {}
plyr.name = 'pierce'
plyr.offset = 2
plyr.ow = 5
plyr.costumes = {
    {name='Pierce Hawthorne', sheet='base'},
    {name='Astronaut', sheet='astronaut'},
    {name='Birthday Suit', sheet='naked'},
    -- {name='Beastmaster', sheet='beast'},
    {name='Canoe', sheet='canoe'},
    {name='Captain Kirk', sheet='kirk'},
    {name='Drugs', sheet='drugs'},
    -- {name='Cookie Crisp Wizard', sheet='cookie'},
    {name='Hotdog', sheet='hotdog'},
    {name='Hula Paint Hallucination', sheet='hulapaint'},
    {name='Janet Reno', sheet='janetreno'},
    {name='The Gimp', sheet='gimp'},
    {name='Level 5 Laser Lotus', sheet='lotus'},
    {name='Magnum', sheet='magnum'},
    {name='Paintball Trooper', sheet='paintball'},
    {name='Planet Christmas', sheet='planet_christmas'},
    {name='Wheelchair', sheet='wheelchair'},
    {name='Zombie', sheet='zombie'},
    -- {name='Pillow Man', sheet='pillow'},
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
            right = anim8.newAnimation('once', g('6,2'), 1),
            left = anim8.newAnimation('once', g('6,1'), 1)
        },
        jump = {
            right = anim8.newAnimation('once', g('7,2'), 1),
            left = anim8.newAnimation('once', g('7,1'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g(7,12), 1),
            left = anim8.newAnimation('once', g(7,11), 1),
        },
        holdwalk = { 
            right = anim8.newAnimation('loop', g('1-4,14'), 0.16),
            left = anim8.newAnimation('loop', g('1-4,13'), 0.16),
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-5,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-5,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        },
        crouch = {
            right = anim8.newAnimation('once', g(3,6), 1),
            left = anim8.newAnimation('once', g(3,5), 1)
        },
        crouchwalk = { --state for walking towards the camera
            right = anim8.newAnimation('loop', g('2-3,3'), 0.16),
            left = anim8.newAnimation('loop', g('2-3,3'), 0.16)
        },
        gaze = {
            right = anim8.newAnimation('once', g(8,2), 1),
            left = anim8.newAnimation('once', g(8,1), 1)
        },
        gazewalk = { --state for walking away from the camera
            right = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16)
        },
        warp = anim8.newAnimation('once', warp('1-4,1'), 0.08)
    }
    return new_plyr
end

return plyr
