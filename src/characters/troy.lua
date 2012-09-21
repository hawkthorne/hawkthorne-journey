local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'troy'
plyr.offset = 8
plyr.ow = 6
plyr.costumes = {
    {name='Troy Barnes', sheet='images/troy.png'},
    -- {name='Barry the Plumber', sheet='images/troy_barry.png'},
    -- {name='Blanketsburg', sheet='images/troy_blanket.png'},
    {name='Bumblebee', sheet='images/troy_bumblebee.png'},
    {name='Childish Gambino', sheet='images/troy_gambino.png'},
    {name='Christmas Troy', sheet='images/troy_christmas_tree.png'},
    -- {name='Constable Reggie', sheet='images/troy_reggie.png'},
    -- {name='Eddie Murphy', sheet='images/troy_eddie.png'},
    {name='Detective', sheet='images/troy_detective.png'},
    {name='Kickpuncher', sheet='images/troy_kick.png'},
    -- {name='King of Clubs', sheet='images/troy_clubs.png'},
    {name='Library Nerd', sheet='images/troy_library.png'},
    {name='Night Troy', sheet='images/troy_night.png'},
    {name='Orange Paint', sheet='images/troy_orange.png'},
    {name='Ripley', sheet='images/troy_ridley.png'},
    {name='Pant Suit', sheet='images/troy_pantsuit.png'},
    {name='Paintball', sheet='images/troy_paintball.png'},
    {name='Sexy Dracula', sheet='images/troy_sexyvampire.png'},
    {name='Spiderman', sheet='images/troy_spidey.png'},
    {name='Star Quarterback', sheet='images/troy_football.png'},
    {name='Troy and Abed Sewn Together', sheet='images/troy_sewn.png'},

}

local beam = love.graphics.newImage('images/troy_beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')
    new_plyr.beam = beam

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 300, beam:getWidth(),
        beam:getHeight())

    new_plyr.hand_offset = 18
    new_plyr.animations = {
        dead = {
            right = anim8.newAnimation('once', g('9,5'), 1),
            left = anim8.newAnimation('once', g('9,6'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g(5,6), 1),
            left = anim8.newAnimation('once', g(5,5), 1),
        },
        holdwalk = {
            right = anim8.newAnimation('loop', g('4-6,10', '5,10'), 0.16),
            left = anim8.newAnimation('loop', g('4-6,9', '5,9'), 0.16),
        },
        jump = {
            right = anim8.newAnimation('loop', g('5-7,2', '6,2'), 0.10),
            left = anim8.newAnimation('loop', g('5-7,1', '6,1'), 0.10)
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16)
        },
        crouch = {
            right = anim8.newAnimation('once', g(9,2), 1),
            left = anim8.newAnimation('once', g(9,1), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('3-4,3'), 0.16),
            right = anim8.newAnimation('loop', g('3-4,3'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(9,4), 1),
            left = anim8.newAnimation('once', g(9,3), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,4'), 0.16),
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
