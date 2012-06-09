local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'troy'
plyr.offset = 11
plyr.costumes = {
    {name='Troy Barnes', sheet='images/troy.png'},
    {name='Barry the Plumber', sheet='images/troy_barry.png'},
    {name='Blanketsburg', sheet='images/troy_blanket.png'},
    {name='Bumblebee', sheet='images/troy_bumblebee.png'},
    {name='Constable Reggie', sheet='images/troy_reggie.png'},
    {name='Eddie Murphy', sheet='images/troy_eddie.png'},
    {name='Kickpuncher', sheet='images/troy_kick.png'},
    {name='King of Clubs', sheet='images/troy_clubs.png'},
    {name='Library Nerd', sheet='images/troy_library.png'},
    {name='Ripley', sheet='images/troy_ridley.png'},
    {name='Sexy Dracula', sheet='images/troy_sexyvampire.png'},
    {name='Spiderman', sheet='images/troy_spidey.png'},
}

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    new_plyr.animations = {
        jump = {
            right = anim8.newAnimation('loop', g('5-7,2', '6,2'), 0.10),
            left = anim8.newAnimation('loop', g('5-7,1', '6,1'), 0.10)
        },
        walk = {
            right = anim8.newAnimation('loop', g('2-4,2', '3,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-4,1', '3,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }
    return new_plyr
end

return plyr
