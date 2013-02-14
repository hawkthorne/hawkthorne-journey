local game = require 'game'
return{
    name = 'icicle',
    type = 'projectile',
    bounceFactor = -1,
    friction = 1, --0.01 * game.step,
    width = 16,
    height = 16,
    frameWidth = 24,
    frameHeight = 24,
    lift = game.gravity,
    playerCanPickUp = false,
    enemyCanPickUp = false,
    velocity = { x = -230, y = 0 }, --initial velocity
    throwVelocityX = 760, 
    throwVelocityY = 0,
    stayOnScreen = false,
    thrown = false,
    damage = 2,
    horizontalLimit = 330,
    animations = {
        default = {'once', {'1,1'},1},
        thrown = {'once', {'1,1'}, 1},
        finish = {'once', {'1,1'}, 1},
    },
    collide = function(node, dt, mtv_x, mtv_y,projectile)
        if node.isPlayer then return end
        if node.hurt then
            node:hurt(projectile.damage)
            projectile:die()
        end
    end,
}