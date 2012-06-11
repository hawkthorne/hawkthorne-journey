local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'annie'
plyr.offset = 14
plyr.ow = 3
plyr.costumes = {
    {name='Annie Edison', sheet='images/annie.png'},
    {name='Ace of Hearts', sheet='images/annie_hearts.png'},
    {name='Annie Kim', sheet='images/annie_kim.png'},
    {name='Geneva', sheet='images/annie_geneva.png'},
    {name='Little Red Riding Hood', sheet='images/annie_riding.png'},
}

function plyr.new(sheet)
    local new_plyr = {}
    new_plyr.sheet = sheet
    new_plyr.sheet:setFilter('nearest', 'nearest')

    local g = anim8.newGrid(48, 48, new_plyr.sheet:getWidth(),
        new_plyr.sheet:getHeight())

    new_plyr.animations = {
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
        }
    }
    return new_plyr
end

return plyr
