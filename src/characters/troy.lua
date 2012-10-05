local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/troy'

local plyr = {}
plyr.name = 'troy'
plyr.offset = 8
plyr.ow = 6
plyr.costumes = {
    {name='Troy Barnes', sheet='base'},
    -- {name='Barry the Plumber', sheet='barry'},
    -- {name='Blanketsburg', sheet='blanket'},
    {name='Bumblebee', sheet='bumblebee'},
    {name='Childish Gambino', sheet='gambino'},
    {name='Christmas Troy', sheet='christmas_tree'},
    -- {name='Constable Reggie', sheet='reggie'},
    -- {name='Eddie Murphy', sheet='eddie'},
    {name='Detective', sheet='detective'},
    {name='Kickpuncher', sheet='kick'},
    -- {name='King of Clubs', sheet='clubs'},
    {name='Library Nerd', sheet='library'},
    {name='Night Troy', sheet='night'},
    {name='Orange Paint', sheet='orange'},
    {name='Ripley', sheet='ridley'},
    {name='Pant Suit', sheet='pantsuit'},
    {name='Paintball', sheet='paintball'},
    {name='Sexy Dracula', sheet='sexyvampire'},
    {name='Spiderman', sheet='spidey'},
    {name='Star Quarterback', sheet='football'},
    {name='Troy and Abed Sewn Together', sheet='sewn'},
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
