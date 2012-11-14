local anim8 = require 'vendor/anim8'
local Timer = require 'vendor/timer'
local cheat = require 'cheat'
local sound = require 'vendor/TEsound'

return {
	name = 'fish',
	die_sound = 'acorn_squeak',
	height = 44,
	width = 44,
	damage = 1,
	hp = 1,
	jumpkill = false,
	antigravity = true,
	animations = {
		dying = {
			right = {'loop', {'1,1'}, 1},
			left = {'loop', {'1,1'}, 1}
		},
		default = {
			right = {'loop', {'1,1'}, 1},
			left = {'loop', {'1,1'}, 1}
		},
		fall = {
			right = {'loop', {'1,1'}, 1},
			left = {'loop', {'1,1'}, 1}
		}
	},
	update = function(dt, enemy, player)
		if enemy.state == 'default' then	
			if enemy.position.y > ( enemy.node.y + 20) - 180 then
				enemy.position.y = enemy.position.y - (150 * dt)
			else
				enemy.state = 'fall'
			end
		elseif enemy.state == 'fall' then
			if enemy.position.y < ( enemy.node.y + 20) then
				enemy.position.y = enemy.position.y + (150 * dt)
			else
				enemy.state = 'default'
			end
		end
	end
}