local game = require 'game'
return{
  name = 'baseball',
  type = 'projectile',
  bounceFactor = 0.8,
  friction = 0.0001 * game.step,
  width = 9,
  height = 9,
  offset = {x=9, y=0},
  frameWidth = 9,
  frameHeight = 9,
  handle_y = -6,
  handle_x = 3,
  velocity = { x = -400, y = -200 },
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
