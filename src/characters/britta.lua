local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'britta'
plyr.offset = 8
plyr.ow = 1
plyr.costumes = {
    {name='Britta Perry', sheet='images/britta.png'},
    {name='Astronaut', sheet='images/britta_astronaut.png'},
    {name='Asylum', sheet='images/britta_asylum.png'},
    {name='Brittasaurus Rex', sheet='images/britta_dragon.png'},
    -- {name='Cheerleader', sheet='images/britta_cheer.png'},
    {name='Darkest Timeline', sheet='images/britta_dark.png'},
    -- {name='Goth Assistant', sheet='images/britta_goth.png'},
    {name='Kool Kat', sheet='images/britta_cool.png'},
    {name='Me So Christmas', sheet='images/britta_king.png'},
    {name='Modern Warfare', sheet='images/britta_paintball.png'},
    {name='Monster', sheet='images/britta_dino.png'},
    {name='Mute Tree', sheet='images/britta_tree.png'},
    {name='On Peyote', sheet='images/britta_peyote.png'},
    -- {name='Queen of Spades', sheet='images/britta_spades.png'},
    {name='Squirrel', sheet='images/britta_squirrel.png'},
    {name='Teapot', sheet='images/britta_teapot.png'},
    {name='Zombie', sheet='images/britta_zombie.png'},
}

local beam = love.graphics.newImage('images/britta_beam.png')

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    local warp = anim8.newGrid(36, 300, beam:getWidth(),
        beam:getHeight())

    new_plyr.beam = beam
    new_plyr.hand_offset = 20
    new_plyr.animations = {
        dead = {
            right = anim8.newAnimation('once', g('10,2'), 1),
            left = anim8.newAnimation('once', g('10,1'), 1)
        },
        hold = {
            right = anim8.newAnimation('once', g(9,5), 1),
            left = anim8.newAnimation('once', g(8,5), 1),
        },
        holdwalk = { 
            right = anim8.newAnimation('loop', g('1,10', '8,8'), 0.16),
            left = anim8.newAnimation('loop', g('1,11', '8,9'), 0.16),
        },
        crouch = {
            right = anim8.newAnimation('once', g(4,4), 1),
            left = anim8.newAnimation('once', g(5,4), 1)
        },
        crouchwalk = { --state for walking towards the camera
            left = anim8.newAnimation('loop', g('2-3,3'), 0.16),
            right = anim8.newAnimation('loop', g('2-3,3'), 0.16),
        },
        gaze = {
            right = anim8.newAnimation('once', g(2,5), 1),
            left = anim8.newAnimation('once', g(1,5), 1),
        },
        gazeidle = { --state for looking away from the camera
            right = anim8.newAnimation('once', g(1,4), 1),
            left = anim8.newAnimation('once', g(1,4), 1),
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
