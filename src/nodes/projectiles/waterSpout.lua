local game = require 'game'
local Timer = require 'vendor/timer'
local sound = require 'vendor/TEsound'

return{
  name = 'waterSpout',
  type = 'projectile',
  explode_sound = 'waterspout',
  friction = 1,
  width = 24,
  height = 72,
  frameWidth = 24,
  frameHeight = 72,
  solid = true,
  lift = game.gravity,
  playerCanPickUp = false,
  enemyCanPickUp = false,
  canPlayerStore = true,
  --usedAsAmmo = true,
  velocity = { x = 0, y = game.gravity }, --initial velocity
  throwVelocityX = 200,
  throwVelocityY = 0,
  offset = { x = 0, y = 0 },
  thrown = false,
  damage = 5,
  special_damage = {water= 6, epic = 100},
  max_damage = 15,
  horizontalLimit = 600,
  explosive = true,
  explodeTime = 1,
  explode_sound = 'explosion_quiet',
  animations = {
    default = {'loop', {'1-4,1'}, 0.15},
    thrown = {'loop', {'1-4,1'}, 0.15},
    explode = {'once', {'5-15,1'}, .08},
    finish = {'once', {'15,1'}, 1},
  },

  dissolveRock = function(projectile, node)
    Timer.add(math.random(1,1.5), function()
      if not node.dead then
        node:hurt(1)
        projectile.props.dissolveRock(projectile, node)
      end
    end)
  end,

  formRock = function(projectile, x, y)
    local level = projectile.containerLevel
    if not level or not level.map then return end
    local BreakableBlock = require 'nodes/breakable_block'
    local SpriteClass = require 'nodes/sprite'
    x = math.floor(x / level.map.tilewidth) * level.map.tilewidth
    y = math.floor(y / level.map.tileheight) * level.map.tileheight
    local node = {
      x = x,
      y = y,
      width = level.map.tilewidth,
      height = level.map.tileheight,
      name = "lavarock",
      properties = {
        hp = 5,
        sprite = "lava-rock"
      }
    }
    local lavarock = BreakableBlock.new( node, projectile.collider, level )
    local node = {
      x = x,
      y = y - level.map.tileheight,
      width = level.map.tilewidth,
      height = level.map.tileheight,
      properties = {
        animation = "1-4,1",
        speed = "0.25",
        sheet = 'images/steam.png',
        width = level.map.tilewidth,
        height = level.map.tileheight,
        mode = 'loop'
      }
    }
    local steam = SpriteClass.new(node)
    level:addNode(steam)
    Timer.add(math.random(3,5), function()
      level:removeNode(steam)
    end)
    level:addNode(lavarock)
    projectile.props.dissolveRock(projectile, lavarock)
  end,

  update = function(dt, projectile)
    local isLava = false
    local isLavaRock = false

    local shapes = projectile.collider:shapesAt( projectile.position.x, projectile.position.y + projectile.height + 5 )
    for _, shape in ipairs(shapes) do
      if shape.node then
        if shape.node.isLiquid and shape.node.name == "lava" then isLava = true end
        if shape.node.isWall and shape.node.node.name == "lavarock" then isLavaRock = true end
      end
    end
    if isLava and not isLavaRock then
      projectile.props.formRock(projectile, projectile.position.x, projectile.position.y + projectile.height)
    end
  end,

  collide = function(node, dt, mtv_x, mtv_y, projectile)
    if node.isPlayer then return end
    if node.hurt and not (node.isWall and node.node.name == "lavarock") then
      if node.isEnemy then
        if projectile.props.hurting then return end
        projectile.props.hurting = true
        projectile.velocity.x = 0
        -- water spout gets moved to exactly the center of the enemy
        projectile.position.x = node.position.x + (node.width / 2) - (projectile.width / 2)
        sound.playSfx( 'explosion_quiet' )
        projectile.animation = projectile.explodeAnimation
        Timer.add(projectile.explodeTime, function()
          projectile:die()
        end)
        Timer.add(0.5, function()
          node:hurt(projectile.damage, projectile.special_damage, 0)
        end)
      else
        node:hurt(projectile.damage, projectile.special_damage, 0)
        projectile:die()
      end
    end
    if node.isFire and node.die then
      node:die()
    end
  end,
}
