local game = require 'game'
return{
    name = 'basketball',
    type = 'projectile',
    bounceFactor = 0.8,
    friction = 0.01 * game.step,
    width = 18,
    height = 16,
    frameWidth = 18,
    frameHeight = 16,
    velocity = { x=300, y=-30 },
    throwVelocityX = 300, 
    throwVelocityY = -100,
    damage = 1,
    collide = function(node, dt, mtv_x, mtv_y,projectile)
        if not node.isPlayer then return end
        if projectile.thrown then
            node:die(projectile.damage)
        end
    end,
    collide_end = function(node, dt,projectile)
    end,
    animations = {
        default = {'once', {'1,1'}, 1},
        thrown = {'once', {'1,1'}, 1},
        finish = {'once', {'1,1'}, 1},
    }
}
