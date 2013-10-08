local game = require 'game'
return{
    name = 'shuriken',
    type = 'projectile',
    friction = 1, --0.01 * game.step,
    width = 17,
    height = 17,
    frameWidth = 24,
    frameHeight = 24,
    solid = true,
    lift = game.gravity,
    playerCanPickUp = false,
    enemyCanPickUp = false,
    canPlayerStore = true,
    velocity = { x = -230, y = 0 }, --initial velocity
    throwVelocityX = 600, 
    throwVelocityY = 0,
    stayOnScreen = false,
    thrown = false,
    damage = 4,
    horizontalLimit = 600,
    animations = {
        default = {'loop', {'1-2,1'}, .1},
        thrown = {'loop', {'1-2,1'}, .1},
        finish = {'loop', {'1-2,1'}, .1},
    },
    collide = function(node, dt, mtv_x, mtv_y,projectile)
        if node.isPlayer then return end
        if node.hurt then
            node:hurt(projectile.damage)
            projectile:die()
        end
    end,
}
