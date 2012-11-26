local game = require 'game'
return{
    name = 'rainbowbeam',
    type = 'projectile',
    bounceFactor = -1,
    friction = 1, --0.01 * game.step,
    width = 16,
    height = 16,
    frameWidth = 16,
    frameHeight = 16,
    lift = game.gravity,
    playerCanPickUp = false,
    enemyCanPickUp = true,
    chargeTime = 5,
    velocity = { x = -230, y = 0 }, --initial vel isn't used since this is insantly picked up
    throwVelocityX = 400, 
    throwVelocityY = 0,
    stayOnScreen = false,
    damage = 1,
    animations = {
        default = {'once', {'1,1','2,1'}, 0.25},
        thrown = {'once', {'2,1'}, 1},
        finish = {'once', {'3,1'}, 1},
    },
    collide = function(node, dt, mtv_x, mtv_y,projectile)
        if not node.isPlayer then return end
        node:die(projectile.damage)
    end,
}