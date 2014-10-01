local game = require 'game'
return{
  name = 'baseball',
  type = 'projectile',
  bounceFactor = 0.8,
  friction = 0.01 * game.step,
  width = 9,
  height = 9,
  offset = {x=9, y=0},
  frameWidth = 9,
  frameHeight = 9,
  velocity = { x = -230, y = -200 },
  stayOnScreen = true,
  playerCanPickUp = true,
  enemyCanPickUp = false,
  canPlayerStore = false,
  thrown = true,
  collide = function(node, dt, mtv_x, mtv_y,projectile)
  end,
  collide_end = function(node, dt,projectile)
  end,
  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'loop', {'1-2,1'}, .10},
    finish = {'once', {'1,1'}, 1},
  }
}
