local anim8 = require 'vendor/anim8'
local coin = require 'nodes/coin'

local properties = {}
properties.setAnimations = function(g)
	animations = {
	dying = {
        right = anim8.newAnimation('once', g('5,2'), 1),
        left = anim8.newAnimation('once', g('5,1'), 1)
       	},
    movement = {
        right = anim8.newAnimation('loop', g('3-4,2'), 0.25),
        left = anim8.newAnimation('loop', g('3-4,1'), 0.25)
    	},
   	attack = {
        right = anim8.newAnimation('loop', g('1-2,2'), 0.25),
        left = anim8.newAnimation('loop', g('1-2,1'), 0.25)
        }
    }
    return animations
end

properties.movement = 'follow'
properties.sound = "hippie_kill"

properties.makeLoot = function(x, y, collider) return {
        coin.new(x, y, collider, 1),
        coin.new(x, y, collider, 1),
        coin.new(x, y, collider, 1),
    }
end

properties.handeParams = function(params)
	if params.ceiling then properties.ceiling = "true" end
end



return properties