local game = require 'game'
return{
    name = 'lightning',
    type = 'projectile',
    bounceFactor = -1,
    friction = 1,
    width = 1391,
    height = 105,
    frameWidth = 126,
    frameHeight = 90,
    lift = game.gravity,
    playerCanPickUp = false,
    enemyCanPickUp = false,
    velocity = { x = -230, y = 0 }, --initial velocity
    throwVelocityX = 400, 
    throwVelocityY = 0,
    stayOnScreen = false,
    thrown = false,
    damage = 4,
    horizontalLimit = 600,
    animations = {
        default = {'once', {'1-11,1'}, 0.1},
        thrown = {'once', {'1-11,1'}, 0.1},
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
