local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'shirley'
plyr.offset = 9
plyr.ow = 2
plyr.costumes = {
    {name='Shirley Bennett', sheet='images/shirley.png'},
    {name='Ace of Clubs', sheet='images/shirley_clubs.png'},
    {name='Chef', sheet='images/shirley_chef.png'},
    {name='Big Cheddar', sheet='images/shirley_anime.png'},
    {name='Crayon', sheet='images/shirley_crayon.png'},
    {name='Harry Potter', sheet='images/shirley_potter.png'},
    -- {name='Jules Winnfield', sheet='images/shirley_jules.png'},
    -- {name='Not Miss Piggy', sheet='images/shirley_glenda.png'},
}

local beam = love.graphics.newImage('images/shirley_beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')
    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 300, beam:getWidth(),
        beam:getHeight())

    new_plyr.hand_offset = 25
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
