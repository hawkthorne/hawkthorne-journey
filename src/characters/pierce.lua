local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'pierce'
plyr.offset = 2
plyr.ow = 5
plyr.costumes = {
    {name='Pierce Hawthorne', sheet='images/pierce.png'},
    {name='Astronaut', sheet='images/pierce_astronaut.png'},
    {name='Birthday Suit', sheet='images/pierce_naked.png'},
    -- {name='Beastmaster', sheet='images/pierce_beast.png'},
    {name='Captain Kirk', sheet='images/pierce_kirk.png'},
    {name='Drugs', sheet='images/pierce_drugs.png'},
    -- {name='Cookie Crisp Wizard', sheet='images/pierce_cookie.png'},
    {name='Hotdog', sheet='images/pierce_hotdog.png'},
	{name='Hula Paint Hallucination', sheet='images/pierce_hulapaint.png'},
    {name='Janet Reno', sheet='images/pierce_janetreno.png'},
    -- {name='The Gimp', sheet='images/pierce_thegimp.png'},
    {name='Level 5 Laser Lotus', sheet='images/pierce_lotus.png'},
    {name='Magnum', sheet='images/pierce_magnum.png'},
    {name='Paintball Trooper', sheet='images/pierce_paintball.png'},
    {name='Planet Christmas', sheet='images/pierce_planet_christmas.png'},
    {name='Wheelchair', sheet='images/pierce_wheelchair.png'},
    {name='Zombie', sheet='images/pierce_zombie.png'},
    -- {name='Pillow Man', sheet='images/pierce_pillow.png'},
}

local beam = love.graphics.newImage('images/pierce_beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')
    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 223, beam:getWidth(),
        beam:getHeight())

    new_plyr.beam = beam
    new_plyr.hand_offsets = {
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 6,32},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{12,32},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{10, 7},{ 5, 5},{ 5, 5} },
        { { 5, 3},{ 5, 5},{ 5, 3},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { {10, 5},{10, 7},{10, 5},{10, 7},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} },
        { { 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5},{ 5, 5} }
    }
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
