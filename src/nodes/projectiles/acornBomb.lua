local game = require 'game'
return{
name = 'acornBomb',
type = 'projectile',
friction = 0.01 * game.step,
width = 44,
height = 30 ,
frameWidth = 44,
frameHeight = 30,
solid = true,
handle_x = 10,
handle_y = -6,
lift = 1,
playerCanPickUp = false,
enemyCanPickUp = true,
canPlayerStore = false,
velocity = { x = 0, y = 0 }, --initial vel isn't used since this is insantly picked up
throwVelocityX = 400,
throwVelocityY = -450,
stayOnScreen = false,
damage = 10,
idletime = 0,
horizontalLimit = 300,
throw_sound = 'acorn_bomb',
animations = {
default = {'loop', {'1,1'}, 0.2},
thrown = {'once', {'2,1','3,1','4,1','5,1','6,1'}, 0.1},
finish = {'once', {'2,1','3,1','4,1','5,1','6,1'}, .1},
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