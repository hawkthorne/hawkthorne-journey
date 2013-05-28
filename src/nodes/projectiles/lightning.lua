local game = require 'game'
local Timer = require 'vendor/timer'
return{
    name = 'lightning',
    type = 'projectile',
    friction = 1,
    width = 100,
    height = 30,
    frameWidth = 100,
    frameHeight = 30,
    solid = true,
    lift = game.gravity,
    playerCanPickUp = false,
    enemyCanPickUp = false,
    velocity = { x = 0, y = 0 }, --initial velocity
    throwVelocityX = 600,
    throwVelocityY = 0,
    offset = { x = 15, y = -15},
    stayOnScreen = false,
    thrown = false,
    damage = 4,
    max_damage = 20,
    horizontalLimit = 600,
    animations = {
        default = {'loop', {'1-3,1'}, 0.1},
        thrown = {'loop', {'1-3,1'}, 0.1},
        finish = {'once', {'1,1'}, 1},
    },
    collide = function(node, dt, mtv_x, mtv_y,projectile)
        if node.isPlayer then return end
        if node.hurt then
            if projectile.props.max_damage > 0 then
                node:hurt(projectile.damage)
                projectile.props.max_damage = projectile.props.max_damage - projectile.damage
            else
                projectile:die()
            end
        end
    end,
}
