local anim8 = require 'vendor/anim8'
local position_matrix_main = require 'positions/britta'

local plyr = {}
plyr.name = 'britta'
plyr.offset = 8
plyr.ow = 1
plyr.costumes = {
    {name='Britta Perry', sheet='base'},
    {name='Astronaut', sheet='astronaut'},
    {name='Asylum', sheet='asylum'},
    {name='Brittasaurus Rex', sheet='dragon'},
    -- {name='Cheerleader', sheet='cheer'},
    {name='Darkest Timeline', sheet='dark'},
    -- {name='Goth Assistant', sheet='goth'},
    {name='Kool Kat', sheet='cool'},
    {name='Me So Christmas', sheet='king'},
    {name='Modern Warfare', sheet='paintball'},
    {name='Monster', sheet='dino'},
    {name='Mute Tree', sheet='tree'},
    {name='On Peyote', sheet='peyote'},
    -- {name='Queen of Spades', sheet='spades'},
    {name='Squirrel', sheet='squirrel'},
    {name='Teapot', sheet='teapot'},
    {name='Zombie', sheet='zombie'},
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
