local game = require 'game'
return{
  name = 'rainbowbeam_tsnake',
  type = 'projectile',
  friction = 1, --0.01 * game.step,
  width = 32,
  height = 26 ,
  frameWidth = 32,
  frameHeight = 26,
  solid = true,
  handle_x = -16,
  handle_y = -25,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,
  velocity = { x = -230, y = 0 }, --initial vel isn't used since this is insantly picked up
  throwVelocityX = 400, 
  throwVelocityY = 0,
  damage = 15,
  idletime = 0,
  throw_sound = 'manicorn_beam',
  animations = {
    default = {'loop', {'1,1','2,1','3,1'}, 0.25},
    --thrown = {'loop', {'1,1','2,1','3,1'}, 0.25},
    thrown = {'loop', {'4,1','5,1'}, 0.25},
    finish = {'once', {'5,1'}, 1},
  },
  
  new = function(projectile)
    local Player = require 'player'
    local player = Player.factory()
    
    local angle = math.atan2(((player.position.y - (player.height - 10)) - projectile.position.y), (player.position.x - projectile.position.x))
    local dx = 300 * math.cos(angle) * (player.position.x < projectile.position.x and -1 or 1)
    local dy = 300 * math.sin(angle) * (player.position.y < projectile.position.y and -1 or 1)
    projectile.angle = angle
    
    projectile.throwVelocity.x = dx
    projectile.throwVelocity.y = dy
  end,
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
