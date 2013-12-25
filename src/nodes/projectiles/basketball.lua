local game = require 'game'
return{
  name = 'basketball',
  type = 'projectile',
  bounceFactor = 0.65 + math.random()/10,
  friction = 0.05 * game.step,
  lift = 0.05 * game.step,
  width = 18,
  height = 16,
  frameWidth = 18,
  frameHeight = 16,
  velocity = { x=300, y=-30 },
  throwVelocityX = 300, 
  throwVelocityY = -200,
  damage = 20,
  special_damage = {blunt = 1},
  playerCanPickUp = false,
  enemyCanPickUp = true,
  canPlayerStore = false,
  collide = function(node, dt, mtv_x, mtv_y,projectile)
    if not node.isPlayer then return end
    if projectile.thrown then
      node:hurt(projectile.damage, projectile.special_damage)
    end
  end,
  collide_end = function(node, dt ,projectile)
  end,
  floor_collide = function(node, new_y, projectile)
    if math.ceil(math.abs(projectile.velocity.x / projectile.friction)) == 1 then
      projectile.collider:remove(projectile.bb)
    end
  end,
  animations = {
    default = {'once', {'1,1'}, 1},
    thrown = {'once', {'1,1'}, 1},
    finish = {'once', {'1,1'}, 1},
  }
}
