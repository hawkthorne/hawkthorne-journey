local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'jeff'
plyr.offset = 5
plyr.ow = 4
plyr.costumes = {
    {name='Jeff Winger', sheet='base'},
    -- {name='Darkest Timeline', sheet='dark'},
    {name='Asylum', sheet='asylum'},
    {name='Birthday Suit', sheet='naked'},
    {name='David Beckham', sheet='david'},
    {name='Electrocuted', sheet='electro'},
    -- {name='Dean Pelton', sheet='dean'},
    {name='Goldblumming', sheet='goldblum'},
    {name='Heather Popandlocklear', sheet='poplock'},
    {name='King of Spades', sheet='spades'},
    {name='Kool Kat', sheet='cool'},
    -- {name='Ricky Nightshade', sheet='ricky'},
    {name='Seacrest Hulk', sheet='hulk'},
    -- {name='Short Shorts', sheet='shorts'},
    {name='Sexy Cowboy', sheet='cowboy'},
    {name='Spanish 101', sheet='abeds_shirt'},
    {name='Zombie', sheet='zombie'},
}

local beam = love.graphics.newImage('images/characters/' .. plyr.name .. '/beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 300, beam:getWidth(),
        beam:getHeight())

    new_plyr.hand_offset = 12
    new_plyr.beam = beam
    new_plyr.animations = {
        dead = {
            right = anim8.newAnimation('once', g('4,6'), 1),
            left = anim8.newAnimation('once', g('4,5'), 1)
        },
        crouch = {
            right = anim8.newAnimation('once', g(3,6), 1),
            left = anim8.newAnimation('once', g(3,5), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('3-4,3'), 0.16),
            right = anim8.newAnimation('loop', g('3-4,3'), 0.16),
        },
        hold = {
            right = anim8.newAnimation('once', g(7,9), 1),
            left = anim8.newAnimation('once', g(7,10), 1),
        },
        holdwalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('1-2,12'), 0.16),
            right = anim8.newAnimation('loop', g('1-2,11'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(5,2), 1),
            left = anim8.newAnimation('once', g(5,1), 1),
        },
        gazewalk = { --state for walking away from the camera
            left = anim8.newAnimation('loop', g('2-3,4'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,4'), 0.16),
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
