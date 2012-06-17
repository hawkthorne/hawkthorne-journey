local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'shirley'
plyr.offset = 13
plyr.ow = 2
plyr.costumes = {
    {name='Shirley Bennet', sheet='images/shirley.png'},
    {name='Ace of Clubs', sheet='images/shirley_clubs.png'},
    {name='Chef', sheet='images/shirley_chef.png'},
    {name='Crayon', sheet='images/shirley_crayon.png'},
    {name='Jules Winnfield', sheet='images/shirley_jules.png'},
    {name='Not Miss Piggy', sheet='images/shirley_glenda.png'},
}

local beam = love.graphics.newImage('images/shirley_beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')
    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 223, beam:getWidth(),
        beam:getHeight())

    new_plyr.beam = beam
    new_plyr.animations = {
        dead = {
            right = anim8.newAnimation('once', g('2,3'), 1),
            left = anim8.newAnimation('once', g('2,3'), 1)
        },
        crouch = {
            right = anim8.newAnimation('once', g(8,3), 1),
            left = anim8.newAnimation('once', g(8,4), 1)
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
