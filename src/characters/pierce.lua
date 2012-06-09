local anim8 = require 'vendor/anim8'

local plyr = {}
plyr.name = 'pierce'
plyr.offset = 2
plyr.costumes = {
    {name='Pierce Hawthorne', sheet='images/pierce.png'},
    {name='Beastmaster', sheet='images/pierce_beast.png'},
    {name='Captain Kirk', sheet='images/pierce_kirk.png'},
    {name='Cookie Crisp Wizard', sheet='images/pierce_cookie.png'},
    {name='Janet Reno', sheet='images/pierce_janetreno.png'},
    {name='The Gimp', sheet='images/pierce_thegimp.png'},
    {name='Pillow Man', sheet='images/pierce_pillow.png'},
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
            right = anim8.newAnimation('loop', g('2-5,2'), 0.16),
            left = anim8.newAnimation('loop', g('2-5,1'), 0.16)
        },
        idle = {
            right = anim8.newAnimation('once', g(1,2), 1),
            left = anim8.newAnimation('once', g(1,1), 1)
        }
    }
    return new_plyr
end

return plyr
