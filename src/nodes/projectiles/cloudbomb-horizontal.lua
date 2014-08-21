local game = require 'game'
return{
name = 'cloudbomb-horizontal',
type = 'projectile',
friction = 0.01 * game.step,
width = 9,
height = 9,
frameWidth = 9,
frameHeight = 9,
handle_x = 5,
handle_y = 5,
solid = true,
lift = game.gravity,
playerCanPickUp = false,
enemyCanPickUp = true,
canPlayerStore = false,
velocity = { x = 400, y = 0}, --initial vel isn't used since this is insantly picked up
throwVelocityX = 400,
throwVelocityY = 0,
horizontalLimit = 400,
stayOnScreen = false,
damage = 10,
idletime = 0,
throw_sound = 'acorn_bomb',
animations = {
default = {'once', {'1-10,1'}, 0.2},
thrown = {'loop', {'10-13,1'}, 0.2},
finish = {'once', {'1-9,1'}, 0.22},
},
collide = function(node, dt, mtv_x, mtv_y,projectile)
if not node.isPlayer then return end
if projectile.thrown then
node:hurt(projectile.damage)
end
end,
update = function(dt,projectile)
if not projectile.holder then
projectile.props.idletime = projectile.props.idletime + dt
else
projectile.props.idletime = 0
end
if projectile.props.idletime > 1.5 then
projectile:die()
end
end,
leave = function(projectile)
projectile:die()
end,
}