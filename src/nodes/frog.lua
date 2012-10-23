local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'

local properties = {}

properties.setAnimations = function(g)
return {
        dying = {
            right = anim8.newAnimation('once', g('5-8,2'), 0.2),
            left = anim8.newAnimation('once', g('5-8,1'), 0.2)
        },
        default = {
            right = anim8.newAnimation('loop', g('1,2'), 1),
            left = anim8.newAnimation('loop', g('1,1'), 1)
        },
	emerge = {
            right = anim8.newAnimation('loop', g('2,2'), 1),
            left = anim8.newAnimation('loop', g('2,1'), 1)
        },
	dive = {
            right = anim8.newAnimation('loop', g('2,2'), 1),
            left = anim8.newAnimation('loop', g('2,1'), 1)
        },
	fall = {
            right = anim8.newAnimation('loop', g('4,2'), 1),
            left = anim8.newAnimation('loop', g('4,1'), 1)
        },
        leap = {
            right = anim8.newAnimation('loop', g('3,2'), 1),
            left = anim8.newAnimation('loop', g('3,1'), 1)
        }
    }
end
properties.movement = 'frog_jump'
properties.die_sound = 'hippie_kill'
properties.speed = 100


function draw()
    if self.dead then
        return
    end

    self:animation():draw(sprite, math.floor(self.position.x),
    math.floor(self.position.y))
end

return properties